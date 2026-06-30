--[[
    ╔══════════════════════════════════════════════════╗
    ║     UNIVERSAL SCRIPT HUB v3.0                    ║
    ║     For Roblox Studio Testing                    ║
    ║     Supports 20+ Game Recreations                ║
    ║                                                  ║
    ║     Games: Arsenal, Rivals, Hypershot,           ║
    ║     Jailbreak, Combat Arena, Steal a Brainrot,   ║
    ║     Murder Mystery 2, Blade Ball,                ║
    ║     Tower of Hell, Da Hood,                      ║
    ║     Natural Disaster Survival, One Tap,          ║
    ║     Bee Swarm Simulator, Flee the Facility,      ║
    ║     Grow a Garden, BloxStrike,                   ║
    ║     Break Your Bones, Slime RNG,                 ║
    ║     Redliners                                    ║
    ╚══════════════════════════════════════════════════╝
    
    USAGE: Paste this entire script into a LocalScript
    inside StarterPlayerScripts in Roblox Studio.
    The script will auto-detect which game recreation
    is loaded and enable game-specific features.
    
    KEYBINDS:
    - RightShift: Toggle GUI visibility
    - F5: Emergency cleanup (remove all modifications)
]]

-- Prevent double execution
if _G.ScriptHubLoaded then
    warn("[Script Hub] Already loaded! Use RightShift to toggle.")
    return
end
_G.ScriptHubLoaded = true

print("[Script Hub] Initializing Universal Script Hub v3.0...")


--[[ ============================================
     CORE UTILITIES & SERVICES
     ============================================ ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Wait for character
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHead()
    local char = getCharacter()
    return char and char:FindFirstChild("Head")
end

-- Connections table for cleanup
local Connections = {}
local ESPObjects = {}
local FlyActive = false
local NoclipActive = false
local BodyVelocity = nil
local BodyGyro = nil

-- Utility functions
local function addConnection(name, conn)
    if Connections[name] then
        Connections[name]:Disconnect()
    end
    Connections[name] = conn
end

local function removeConnection(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

local function cleanupAll()
    for name, conn in pairs(Connections) do
        conn:Disconnect()
    end
    Connections = {}
    for _, obj in pairs(ESPObjects) do
        if typeof(obj) == "Instance" then
            obj:Destroy()
        end
    end
    ESPObjects = {}
end

local function isAlive(player)
    local char = player and player.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if not isAlive(player) then return false end
    -- Team check
    if LocalPlayer.Team and player.Team then
        return LocalPlayer.Team ~= player.Team
    end
    return true
end

local function getClosestEnemy(maxDist, fov)
    local closest = nil
    local closestDist = maxDist or math.huge
    local closestScreenDist = fov or math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character then
            local part = player.Character:FindFirstChild(Settings[CurrentGame] and Settings[CurrentGame]["Aim Part"] or "Head")
                or player.Character:FindFirstChild("Head")
                or player.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if screenDist < closestScreenDist then
                        closestScreenDist = screenDist
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function teleportTo(position)
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(position)
    end
end

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Script Hub",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end


-- Settings storage
local Settings = {}
local CurrentGame = nil

-- Game Data
local GameList = {
        {
            id = "arsenal",
            name = "Arsenal",
            icon = "🔫",
            genre = "FPS",
            description = "Fast-paced FPS gun game. Cycle through weapons with each kill.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Aimbot Smoothness", type = "slider", category = "Combat", defaultValue = 5, min = 1, max = 20},
            {name = "Aim Part", type = "dropdown", category = "Combat", defaultValue = "Head", options = {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "FOV Circle", type = "toggle", category = "Combat", defaultValue = true},
            {name = "FOV Radius", type = "slider", category = "Combat", defaultValue = 150, min = 50, max = 500},
            {name = "No Recoil", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Spread", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Rapid Fire", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Fire Rate Multiplier", type = "slider", category = "Combat", defaultValue = 2, min = 1, max = 10},
            {name = "Auto Shoot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Health Bars", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Distance", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Weapon", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Tracers", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Chams", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Cham Color (Enemy)", type = "dropdown", category = "Visuals", defaultValue = "Red", options = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange", "Cyan"}},
            {name = "Kill All", type = "button", category = "Utility", defaultValue = false},
            {name = "Infinite Ammo", type = "toggle", category = "Utility", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 100},
            {name = "Jump Power", type = "slider", category = "Movement", defaultValue = 50, min = 50, max = 200},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Fly Speed", type = "slider", category = "Movement", defaultValue = 50, min = 10, max = 200},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Teleport to Spawn", type = "button", category = "Movement", defaultValue = false},
            {name = "Auto Reload", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "rivals",
            name = "Rivals",
            icon = "⚔️",
            genre = "FPS",
            description = "Competitive tactical FPS with unique abilities and team-based gameplay.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Aimbot Smoothness", type = "slider", category = "Combat", defaultValue = 8, min = 1, max = 25},
            {name = "Aim Part", type = "dropdown", category = "Combat", defaultValue = "Head", options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "FOV Circle", type = "toggle", category = "Combat", defaultValue = true},
            {name = "FOV Radius", type = "slider", category = "Combat", defaultValue = 180, min = 50, max = 600},
            {name = "No Recoil", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Spread", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Sway", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Rapid Fire", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Shoot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Instant Ability", type = "toggle", category = "Combat", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Health", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Distance", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Tracers", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Chams/Highlights", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Bomb ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Ability ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Jump Power", type = "slider", category = "Movement", defaultValue = 50, min = 50, max = 200},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Infinite Ammo", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Auto Plant/Defuse", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "hypershot",
            name = "Hypershot",
            icon = "💥",
            genre = "FPS",
            description = "High-speed arena shooter with fast movement and futuristic weapons.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Aimbot Smoothness", type = "slider", category = "Combat", defaultValue = 6, min = 1, max = 20},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "FOV Circle", type = "toggle", category = "Combat", defaultValue = true},
            {name = "FOV Radius", type = "slider", category = "Combat", defaultValue = 200, min = 50, max = 500},
            {name = "No Recoil", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Spread", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Rapid Fire", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Shoot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Projectile Speed Boost", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Instant Charge", type = "toggle", category = "Combat", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Health", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Tracers", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Chams", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Pickup ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Power-Up ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 120},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Infinite Dash", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Auto Pickup", type = "toggle", category = "Automation", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Infinite Ammo", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "jailbreak",
            name = "Jailbreak",
            icon = "🚔",
            genre = "Open World",
            description = "Prison escape and cops vs criminals open-world action game.",
            features = {
            {name = "Auto Rob", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Rob Delay", type = "slider", category = "Automation", defaultValue = 3, min = 1, max = 15},
            {name = "Auto Collect Drops", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Arrest", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Escape", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Infinite Nitro", type = "toggle", category = "Vehicle", defaultValue = false},
            {name = "Vehicle Speed Multiplier", type = "slider", category = "Vehicle", defaultValue = 1, min = 1, max = 10},
            {name = "Vehicle Fly", type = "toggle", category = "Vehicle", defaultValue = false},
            {name = "Vehicle Noclip", type = "toggle", category = "Vehicle", defaultValue = false},
            {name = "No Vehicle Damage", type = "toggle", category = "Vehicle", defaultValue = false},
            {name = "Teleport to Bank", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Jewelry Store", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Museum", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Power Plant", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Casino", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Criminal Base", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Police Station", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Garage", type = "button", category = "Teleport", defaultValue = false},
            {name = "ESP Players", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Cops", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Criminals", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Vehicles", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Robbery Status", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 100},
            {name = "Jump Power", type = "slider", category = "Movement", defaultValue = 50, min = 50, max = 200},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Remove All Doors", type = "button", category = "Utility", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Infinite Cash", type = "button", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "combat-arena",
            name = "Combat Arena",
            icon = "🗡️",
            genre = "Fighting",
            description = "Arena-based combat with melee and ranged weapons.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Parry", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Combo", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Block", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Hit Range Extender", type = "slider", category = "Combat", defaultValue = 1, min = 1, max = 5},
            {name = "Attack Speed", type = "slider", category = "Combat", defaultValue = 1, min = 1, max = 5},
            {name = "No Attack Cooldown", type = "toggle", category = "Combat", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Health", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Attack Range Circle", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Kill Aura", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Kill Aura Range", type = "slider", category = "Combat", defaultValue = 15, min = 5, max = 50},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "steal-a-brainrot",
            name = "Steal a Brainrot",
            icon = "🧠",
            genre = "Collecting",
            description = "Collect and steal brainrot memes/items from other players.",
            features = {
            {name = "Auto Collect", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Steal", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Collect Range", type = "slider", category = "Automation", defaultValue = 20, min = 5, max = 100},
            {name = "Teleport to Items", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Store", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Farm Loop", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Item ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Rare Item ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Player ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Safe Zone ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 100},
            {name = "Jump Power", type = "slider", category = "Movement", defaultValue = 50, min = 50, max = 200},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Teleport to Nearest Item", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Safe Zone", type = "button", category = "Teleport", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-Steal", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "murder-mystery-2",
            name = "Murder Mystery 2",
            icon = "🔪",
            genre = "Mystery",
            description = "Classic murder mystery. Murderer, Sheriff, and Innocents.",
            features = {
            {name = "Murderer ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Sheriff ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Role Reveal", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Gun ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Player ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Coin ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Trap ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Auto Collect Coins", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Grab Gun", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Shoot Murderer", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Murderer Alert", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Alert Distance", type = "slider", category = "Utility", defaultValue = 30, min = 10, max = 100},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Instant Knife Throw", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Extended Knife Range", type = "slider", category = "Combat", defaultValue = 5, min = 5, max = 25},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "blade-ball",
            name = "Blade Ball",
            icon = "⚽",
            genre = "Action",
            description = "Deflect the ball at the right moment or get eliminated.",
            features = {
            {name = "Auto Parry", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Parry Timing Offset", type = "slider", category = "Combat", defaultValue = 50, min = 0, max = 200},
            {name = "Auto Spam Click", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Curve Ball", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Ball Speed Prediction", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Ball ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Target ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Player ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Proximity Warning", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Warning Distance", type = "slider", category = "Visuals", defaultValue = 50, min = 20, max = 150},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Auto Equip Best Sword", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Ability", type = "toggle", category = "Automation", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "tower-of-hell",
            name = "Tower of Hell",
            icon = "🗼",
            genre = "Obby",
            description = "Randomly generated obby tower. Race to the top!",
            features = {
            {name = "Infinite Jump", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Fly Speed", type = "slider", category = "Movement", defaultValue = 50, min = 10, max = 200},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 100},
            {name = "Jump Power", type = "slider", category = "Movement", defaultValue = 50, min = 50, max = 300},
            {name = "Teleport to Top", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Next Section", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Start", type = "button", category = "Teleport", defaultValue = false},
            {name = "Auto Win", type = "button", category = "Automation", defaultValue = false},
            {name = "Remove Kill Bricks", type = "button", category = "Utility", defaultValue = false},
            {name = "Remove Spinners", type = "button", category = "Utility", defaultValue = false},
            {name = "Remove All Obstacles", type = "button", category = "Utility", defaultValue = false},
            {name = "Highlight Kill Bricks", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Highlight Safe Platforms", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Section Labels", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Path Finder", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Platform Transparency", type = "slider", category = "Visuals", defaultValue = 0, min = 0, max = 90},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "da-hood",
            name = "Da Hood",
            icon = "🏘️",
            genre = "Fighting/RP",
            description = "Hood life roleplay with combat, stomp mechanics, and carrying.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Aimbot Smoothness", type = "slider", category = "Combat", defaultValue = 5, min = 1, max = 20},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Stomp", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Stomp Aura", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Stomp Range", type = "slider", category = "Combat", defaultValue = 15, min = 5, max = 50},
            {name = "Auto Carry & Throw", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Recoil", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Spread", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Rapid Fire", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Triggerbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Health", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Cash ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Weapon ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Tracers", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Teleport to ATM", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Gun Shop", type = "button", category = "Teleport", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "natural-disaster-survival",
            name = "Natural Disaster Survival",
            icon = "🌪️",
            genre = "Survival",
            description = "Survive random natural disasters on various island maps.",
            features = {
            {name = "Disaster Prediction", type = "toggle", category = "Utility", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Auto Safe Spot", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Safe Spot ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Disaster ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Player ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Survivor Count", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Jump Power", type = "slider", category = "Movement", defaultValue = 50, min = 50, max = 200},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Infinite Jump", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Anchor Character", type = "toggle", category = "Utility", defaultValue = false},
            {name = "No Fall Damage", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti Fire", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Auto Survive", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "one-tap",
            name = "One Tap",
            icon = "🎯",
            genre = "FPS",
            description = "One-shot kill FPS game. Every shot is lethal.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Aimbot Smoothness", type = "slider", category = "Combat", defaultValue = 3, min = 1, max = 15},
            {name = "Aim Part", type = "dropdown", category = "Combat", defaultValue = "Head", options = {"Head", "HumanoidRootPart", "UpperTorso"}},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "FOV Circle", type = "toggle", category = "Combat", defaultValue = true},
            {name = "FOV Radius", type = "slider", category = "Combat", defaultValue = 200, min = 50, max = 600},
            {name = "Auto Shoot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Triggerbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Scope Sway", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Quickscope Assist", type = "toggle", category = "Combat", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Tracers", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Chams", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "bee-swarm-simulator",
            name = "Bee Swarm Simulator",
            icon = "🐝",
            genre = "Simulator",
            description = "Collect pollen with bees, make honey, and grow your swarm.",
            features = {
            {name = "Auto Farm Pollen", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Farm Field", type = "dropdown", category = "Automation", defaultValue = "Sunflower", options = {"Sunflower", "Dandelion", "Mushroom", "Blue Flower", "Clover", "Strawberry", "Spider", "Bamboo", "Pineapple", "Stump", "Cactus", "Pumpkin", "Pine Tree", "Rose", "Mountain Top", "Coconut", "Pepper"}},
            {name = "Auto Convert Honey", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Collect Tokens", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Collect Sprouts", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Use Abilities", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Quest", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Feed Treats", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Macro", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Macro Loop Delay", type = "slider", category = "Automation", defaultValue = 5, min = 1, max = 30},
            {name = "Token ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Sprout ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Treasure ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Mob ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Teleport to Hive", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Shop", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Bear", type = "button", category = "Teleport", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 100},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Infinite Capacity", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "flee-the-facility",
            name = "Flee the Facility",
            icon = "🏃",
            genre = "Horror/Survival",
            description = "Hack computers and escape before the beast catches you.",
            features = {
            {name = "Beast ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Player ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Computer ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Computer Progress", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Exit ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Chest ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Beast Proximity Alert", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Alert Distance", type = "slider", category = "Utility", defaultValue = 40, min = 10, max = 100},
            {name = "Auto Hack", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Instant Hack", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Rescue", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Crawl Speed Boost", type = "slider", category = "Movement", defaultValue = 10, min = 10, max = 50},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Auto Escape", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "grow-a-garden",
            name = "Grow a Garden",
            icon = "🌱",
            genre = "Simulator",
            description = "Plant seeds, water them, and grow a beautiful garden.",
            features = {
            {name = "Auto Plant", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Seed Type", type = "dropdown", category = "Automation", defaultValue = "Sunflower", options = {"Sunflower", "Rose", "Tulip", "Lily", "Daisy", "Orchid", "Cactus", "Bonsai", "Mushroom", "Crystal Flower", "Rainbow Rose", "Golden Bloom"}},
            {name = "Auto Water", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Harvest", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Sell", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Fertilize", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Full Farm Loop", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Farm Loop Speed", type = "slider", category = "Automation", defaultValue = 2, min = 1, max = 10},
            {name = "Instant Grow", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Infinite Water", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Plant ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Rare Seed ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Shop ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Growth Timer", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Teleport to Shop", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Garden", type = "button", category = "Teleport", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "bloxstrike",
            name = "BloxStrike",
            icon = "💣",
            genre = "FPS",
            description = "Counter-Strike inspired tactical FPS on Roblox.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Aimbot Smoothness", type = "slider", category = "Combat", defaultValue = 6, min = 1, max = 20},
            {name = "Aim Part", type = "dropdown", category = "Combat", defaultValue = "Head", options = {"Head", "HumanoidRootPart", "UpperTorso"}},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "FOV Circle", type = "toggle", category = "Combat", defaultValue = true},
            {name = "FOV Radius", type = "slider", category = "Combat", defaultValue = 160, min = 50, max = 500},
            {name = "No Recoil", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Spread", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Rapid Fire", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Shoot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Bunny Hop", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Auto Defuse/Plant", type = "toggle", category = "Automation", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Health", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Weapons", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Bomb ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Tracers", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Chams", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Infinite Money", type = "button", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "break-your-bones",
            name = "Break Your Bones",
            icon = "🦴",
            genre = "Ragdoll",
            description = "Launch yourself and break as many bones as possible for points.",
            features = {
            {name = "Super Launch", type = "toggle", category = "Physics", defaultValue = false},
            {name = "Launch Force Multiplier", type = "slider", category = "Physics", defaultValue = 5, min = 1, max = 50},
            {name = "Infinite Bounces", type = "toggle", category = "Physics", defaultValue = false},
            {name = "Anti-Gravity", type = "toggle", category = "Physics", defaultValue = false},
            {name = "Gravity Multiplier", type = "slider", category = "Physics", defaultValue = 100, min = 10, max = 200},
            {name = "Max Bone Breaks", type = "button", category = "Utility", defaultValue = false},
            {name = "Score Multiplier", type = "slider", category = "Utility", defaultValue = 1, min = 1, max = 100},
            {name = "Auto Launch Optimal", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Reset", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Reset Delay", type = "slider", category = "Automation", defaultValue = 2, min = 1, max = 10},
            {name = "Teleport to Best Launch Spot", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Top of Map", type = "button", category = "Teleport", defaultValue = false},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Trajectory Preview", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Landing Zone ESP", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "slime-rng",
            name = "Slime RNG",
            icon = "🟢",
            genre = "RNG",
            description = "Roll for slimes with different rarities. Chase that 1 in a million!",
            features = {
            {name = "Auto Roll", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Roll Speed", type = "slider", category = "Automation", defaultValue = 1, min = 1, max = 20},
            {name = "Auto Sell Duplicates", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Minimum Rarity Keep", type = "dropdown", category = "Automation", defaultValue = "Rare", options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine", "Celestial"}},
            {name = "Auto Equip Best", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Use Potions", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Rebirth", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Auto Craft", type = "toggle", category = "Automation", defaultValue = false},
            {name = "Luck Boost", type = "slider", category = "Utility", defaultValue = 1, min = 1, max = 100},
            {name = "Instant Roll", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Roll History Log", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Rare Roll Alert", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Collection Display", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Odds Display", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Teleport to Roll Area", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Shop", type = "button", category = "Teleport", defaultValue = false},
            {name = "Teleport to Trade Area", type = "button", category = "Teleport", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        },
        {
            id = "redliners",
            name = "Redliners",
            icon = "🔴",
            genre = "FPS",
            description = "Fast-paced FPS with intense gunfights and tactical gameplay.",
            features = {
            {name = "Aimbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Aimbot Smoothness", type = "slider", category = "Combat", defaultValue = 5, min = 1, max = 20},
            {name = "Aim Part", type = "dropdown", category = "Combat", defaultValue = "Head", options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}},
            {name = "Silent Aim", type = "toggle", category = "Combat", defaultValue = false},
            {name = "FOV Circle", type = "toggle", category = "Combat", defaultValue = true},
            {name = "FOV Radius", type = "slider", category = "Combat", defaultValue = 180, min = 50, max = 600},
            {name = "No Recoil", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Spread", type = "toggle", category = "Combat", defaultValue = false},
            {name = "No Sway", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Rapid Fire", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Fire Rate Multiplier", type = "slider", category = "Combat", defaultValue = 2, min = 1, max = 10},
            {name = "Auto Shoot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Triggerbot", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Hit Registration Boost", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Auto Reload", type = "toggle", category = "Combat", defaultValue = false},
            {name = "Instant Reload", type = "toggle", category = "Combat", defaultValue = false},
            {name = "ESP Boxes", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Names", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Health Bars", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Distance", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "ESP Weapon Display", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Tracers", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Chams/Highlights", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Cham Color", type = "dropdown", category = "Visuals", defaultValue = "Red", options = {"Red", "Green", "Blue", "Yellow", "Purple", "Cyan", "Orange"}},
            {name = "Crosshair Customizer", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Kill Feed Tracker", type = "toggle", category = "Visuals", defaultValue = false},
            {name = "Speed Boost", type = "slider", category = "Movement", defaultValue = 16, min = 16, max = 80},
            {name = "Jump Power", type = "slider", category = "Movement", defaultValue = 50, min = 50, max = 200},
            {name = "Fly", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Fly Speed", type = "slider", category = "Movement", defaultValue = 50, min = 10, max = 200},
            {name = "Noclip", type = "toggle", category = "Movement", defaultValue = false},
            {name = "Bunny Hop", type = "toggle", category = "Movement", defaultValue = false},
            {name = "God Mode", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Infinite Ammo", type = "toggle", category = "Utility", defaultValue = false},
            {name = "No Flash", type = "toggle", category = "Utility", defaultValue = false},
            {name = "No Smoke", type = "toggle", category = "Utility", defaultValue = false},
            {name = "Teleport to Spawn", type = "button", category = "Movement", defaultValue = false},
            {name = "Kill All", type = "button", category = "Utility", defaultValue = false},
            {name = "Anti-AFK", type = "toggle", category = "Automation", defaultValue = true}
            }
        }
}

-- Initialize settings with defaults
for _, gameData in ipairs(GameList) do
    Settings[gameData.id] = {}
    for _, feature in ipairs(gameData.features) do
        if feature.defaultValue ~= nil then
            Settings[gameData.id][feature.name] = feature.defaultValue
        end
    end
end

-- Game Detection
local function detectGame()
    local placeId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or ""
    gameName = string.lower(gameName)
    
    local gameMap = {
        ["arsenal"] = {"arsenal", "arsenal"},
        ["rivals"] = {"rivals", "rivals"},
        ["hypershot"] = {"hypershot", "hypershot"},
        ["jailbreak"] = {"jailbreak", "jailbreak"},
        ["combat-arena"] = {"combat arena", "combat-arena"},
        ["steal-a-brainrot"] = {"steal a brainrot", "steal-a-brainrot"},
        ["murder-mystery-2"] = {"murder mystery 2", "murder-mystery-2"},
        ["blade-ball"] = {"blade ball", "blade-ball"},
        ["tower-of-hell"] = {"tower of hell", "tower-of-hell"},
        ["da-hood"] = {"da hood", "da-hood"},
        ["natural-disaster-survival"] = {"natural disaster survival", "natural-disaster-survival"},
        ["one-tap"] = {"one tap", "one-tap"},
        ["bee-swarm-simulator"] = {"bee swarm simulator", "bee-swarm-simulator"},
        ["flee-the-facility"] = {"flee the facility", "flee-the-facility"},
        ["grow-a-garden"] = {"grow a garden", "grow-a-garden"},
        ["bloxstrike"] = {"bloxstrike", "bloxstrike"},
        ["break-your-bones"] = {"break your bones", "break-your-bones"},
        ["slime-rng"] = {"slime rng", "slime-rng"},
        ["redliners"] = {"redliners", "redliners"}
    }
    
    for id, data in pairs(gameMap) do
        if string.find(gameName, data[1]) or string.find(gameName, id) then
            return id
        end
    end
    
    -- Fallback: check workspace for game-specific objects
    if workspace:FindFirstChild("Weapons") or workspace:FindFirstChild("GunSystem") then return "arsenal" end
    if workspace:FindFirstChild("Weapons") or workspace:FindFirstChild("GunSystem") then return "rivals" end
    if workspace:FindFirstChild("Weapons") or workspace:FindFirstChild("GunSystem") then return "hypershot" end
    if workspace:FindFirstChild("Vehicles") and workspace:FindFirstChild("Robberies") then return "jailbreak" end
    if workspace:FindFirstChild("GunDrop") or workspace:FindFirstChild("Knife") then return "murder-mystery-2" end
    if workspace:FindFirstChild("Ball") or workspace:FindFirstChild("BladeBall") then return "blade-ball" end
    if workspace:FindFirstChild("Tower") or workspace:FindFirstChild("Sections") then return "tower-of-hell" end
    if workspace:FindFirstChild("Weapons") or workspace:FindFirstChild("GunSystem") then return "one-tap" end
    if workspace:FindFirstChild("FlowerZones") or workspace:FindFirstChild("Hives") then return "bee-swarm-simulator" end
    if workspace:FindFirstChild("Weapons") or workspace:FindFirstChild("GunSystem") then return "bloxstrike" end
    if workspace:FindFirstChild("Weapons") or workspace:FindFirstChild("GunSystem") then return "redliners" end
    
    return nil -- Unknown game
end


--[[ ============================================
     ESP SYSTEM
     ============================================ ]]

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = Camera

local function createESPForPlayer(player, color)
    if player == LocalPlayer then return end
    
    local function setupESP(character)
        -- Cleanup old ESP
        local oldFolder = ESPFolder:FindFirstChild(player.Name)
        if oldFolder then oldFolder:Destroy() end
        
        local espFolder = Instance.new("Folder")
        espFolder.Name = player.Name
        espFolder.Parent = ESPFolder
        
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        local humanoid = character:WaitForChild("Humanoid", 5)
        local head = character:WaitForChild("Head", 5)
        if not (hrp and humanoid and head) then return end
        
        -- Billboard for name/health/distance
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPBillboard"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = espFolder
        
        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = color or Color3.fromRGB(255, 0, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.Text = player.Name
        nameLabel.Parent = billboard
        
        -- Health label
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.4, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        healthLabel.TextStrokeTransparency = 0
        healthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextSize = 11
        healthLabel.Text = ""
        healthLabel.Parent = billboard
        
        -- Distance label
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distLabel.Position = UDim2.new(0, 0, 0.7, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 10
        distLabel.Text = ""
        distLabel.Parent = billboard
        
        -- Highlight (chams)
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = color or Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = color or Color3.fromRGB(255, 0, 0)
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = espFolder
        highlight.Enabled = false
        
        -- Box ESP via SelectionBox
        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ESPBox"
        selectionBox.Adornee = character
        selectionBox.Color3 = color or Color3.fromRGB(255, 0, 0)
        selectionBox.LineThickness = 0.02
        selectionBox.Parent = espFolder
        selectionBox.Visible = false
        
        -- Tracer (beam from character to enemy)
        -- We'll use a part-based approach
        
        -- Update loop
        local updateConn
        updateConn = RunService.RenderStepped:Connect(function()
            if not character or not character.Parent or not humanoid or humanoid.Health <= 0 then
                espFolder:Destroy()
                if updateConn then updateConn:Disconnect() end
                return
            end
            
            local myHRP = getHRP()
            if myHRP and hrp then
                local dist = (myHRP.Position - hrp.Position).Magnitude
                distLabel.Text = string.format("%.0f studs", dist)
            end
            
            healthLabel.Text = string.format("HP: %.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
            
            local gs = Settings[CurrentGame] or {}
            
            -- Toggle visibility based on settings
            billboard.Enabled = gs["ESP Names"] or gs["ESP Health"] or gs["ESP Distance"] or 
                               gs["ESP Health Bars"] or gs["Player ESP"] or gs["ESP Boxes"] or
                               gs["Beast ESP"] or gs["Murderer ESP"] or gs["Sheriff ESP"] or
                               gs["ESP Cops"] or gs["ESP Criminals"] or false
            nameLabel.Visible = gs["ESP Names"] or gs["Player ESP"] or gs["Role Reveal"] or false
            healthLabel.Visible = gs["ESP Health"] or gs["ESP Health Bars"] or false
            distLabel.Visible = gs["ESP Distance"] or false
            
            highlight.Enabled = gs["Chams"] or gs["Chams/Highlights"] or false
            selectionBox.Visible = gs["ESP Boxes"] or false
        end)
        
        table.insert(ESPObjects, espFolder)
    end
    
    if player.Character then
        setupESP(player.Character)
    end
    player.CharacterAdded:Connect(setupESP)
end

local function initESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local color = Color3.fromRGB(255, 0, 0)
            if isEnemy(player) then
                color = Color3.fromRGB(255, 50, 50)
            else
                color = Color3.fromRGB(50, 255, 50)
            end
            createESPForPlayer(player, color)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        local color = isEnemy(player) and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
        createESPForPlayer(player, color)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        local folder = ESPFolder:FindFirstChild(player.Name)
        if folder then folder:Destroy() end
    end)
end



--[[ ============================================
     COMBAT SYSTEM (Aimbot, Silent Aim, etc.)
     ============================================ ]]

local AimbotTarget = nil
local FOVCircle = nil

-- Create FOV circle
local function createFOVCircle()
    if FOVCircle then FOVCircle:Remove() end
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = 150
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 0.7
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    return FOVCircle
end

pcall(createFOVCircle)

local function initAimbot()
    addConnection("Aimbot", RunService.RenderStepped:Connect(function()
        local gs = Settings[CurrentGame] or {}
        
        -- FOV Circle update
        if FOVCircle then
            FOVCircle.Visible = gs["FOV Circle"] or false
            FOVCircle.Radius = gs["FOV Radius"] or 150
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
        
        if not gs["Aimbot"] then
            AimbotTarget = nil
            return
        end
        
        local fovRadius = gs["FOV Radius"] or 150
        local smoothness = gs["Aimbot Smoothness"] or 5
        local aimPart = gs["Aim Part"] or "Head"
        
        local target = getClosestEnemy(math.huge, fovRadius)
        AimbotTarget = target
        
        if target and target.Character then
            local part = target.Character:FindFirstChild(aimPart) or target.Character:FindFirstChild("Head")
            if part then
                local targetCFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / math.max(smoothness, 1))
            end
        end
    end))
end

local function initAutoShoot()
    addConnection("AutoShoot", RunService.RenderStepped:Connect(function()
        local gs = Settings[CurrentGame] or {}
        if not (gs["Auto Shoot"] or gs["Triggerbot"]) then return end
        
        if AimbotTarget and isAlive(AimbotTarget) then
            -- Simulate mouse click
            pcall(function()
                mouse1click()
            end)
        end
    end))
end

local function initNoRecoil()
    addConnection("NoRecoil", RunService.RenderStepped:Connect(function()
        local gs = Settings[CurrentGame] or {}
        if not gs["No Recoil"] then return end
        
        -- Attempt to neutralize recoil by resetting camera offset
        pcall(function()
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        -- Look for recoil-related values
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("NumberValue") and (string.lower(v.Name):find("recoil") or string.lower(v.Name):find("spread")) then
                                if gs["No Recoil"] and string.lower(v.Name):find("recoil") then
                                    v.Value = 0
                                end
                                if gs["No Spread"] and string.lower(v.Name):find("spread") then
                                    v.Value = 0
                                end
                            end
                        end
                    end
                end
            end
        end)
    end))
end



--[[ ============================================
     MOVEMENT SYSTEM (Fly, Noclip, Speed, Jump)
     ============================================ ]]

local function initMovementHacks()
    -- Speed and Jump updater
    addConnection("SpeedJump", RunService.Heartbeat:Connect(function()
        local gs = Settings[CurrentGame] or {}
        local hum = getHumanoid()
        if not hum then return end
        
        local speed = gs["Speed Boost"]
        if speed and speed > 16 then
            hum.WalkSpeed = speed
        end
        
        local jump = gs["Jump Power"]
        if jump and jump > 50 then
            hum.JumpPower = jump
            hum.UseJumpPower = true
        end
    end))
    
    -- Noclip
    addConnection("Noclip", RunService.Stepped:Connect(function()
        local gs = Settings[CurrentGame] or {}
        if not gs["Noclip"] then return end
        
        local char = getCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end))
    
    -- Infinite Jump
    addConnection("InfJump", UserInputService.JumpRequest:Connect(function()
        local gs = Settings[CurrentGame] or {}
        if not gs["Infinite Jump"] then return end
        
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

local function toggleFly(enabled)
    local hrp = getHRP()
    local hum = getHumanoid()
    if not (hrp and hum) then return end
    
    if enabled then
        FlyActive = true
        
        if BodyVelocity then BodyVelocity:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BodyVelocity.Velocity = Vector3.zero
        BodyVelocity.Parent = hrp
        
        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        BodyGyro.P = 9000
        BodyGyro.CFrame = hrp.CFrame
        BodyGyro.Parent = hrp
        
        addConnection("Fly", RunService.RenderStepped:Connect(function()
            if not FlyActive then return end
            local gs = Settings[CurrentGame] or {}
            local flySpeed = gs["Fly Speed"] or 50
            
            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            if direction.Magnitude > 0 then
                direction = direction.Unit
            end
            
            BodyVelocity.Velocity = direction * flySpeed
            BodyGyro.CFrame = Camera.CFrame
        end))
        
        hum:ChangeState(Enum.HumanoidStateType.Flying)
    else
        FlyActive = false
        removeConnection("Fly")
        if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity = nil end
        if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end
    end
end

local function initFlyToggle()
    addConnection("FlyCheck", RunService.Heartbeat:Connect(function()
        local gs = Settings[CurrentGame] or {}
        local shouldFly = gs["Fly"] or false
        
        if shouldFly and not FlyActive then
            toggleFly(true)
        elseif not shouldFly and FlyActive then
            toggleFly(false)
        end
    end))
end



--[[ ============================================
     GOD MODE / UTILITY SYSTEMS
     ============================================ ]]

local function initGodMode()
    addConnection("GodMode", RunService.Heartbeat:Connect(function()
        local gs = Settings[CurrentGame] or {}
        if not gs["God Mode"] then return end
        
        local hum = getHumanoid()
        if hum then
            hum.Health = hum.MaxHealth
        end
    end))
end

local function initAntiAFK()
    -- Override idle connection
    local VirtualUser = game:GetService("VirtualUser")
    addConnection("AntiAFK", LocalPlayer.Idled:Connect(function()
        local gs = Settings[CurrentGame] or {}
        if gs["Anti-AFK"] then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            notify("Anti-AFK", "Prevented idle kick!")
        end
    end))
end



-- ============================================
-- GAME-SPECIFIC: ARSENAL
-- ============================================

local function initArsenal()
    notify("Script Hub", "Arsenal module loaded!")
    
    -- Infinite Ammo
    addConnection("arsenal_infammo", RunService.Heartbeat:Connect(function()
        local gs = Settings["arsenal"] or {}
        if not gs["Infinite Ammo"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("NumberValue") or v:IsA("IntValue") then
                                local n = string.lower(v.Name)
                                if n:find("ammo") or n:find("clip") or n:find("magazine") then
                                    v.Value = math.max(v.Value, 999)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Reload
    addConnection("arsenal_reload", RunService.Heartbeat:Connect(function()
        local gs = Settings["arsenal"] or {}
        if not gs["Auto Reload"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("NumberValue") and string.lower(v.Name):find("ammo") then
                                if v.Value <= 0 then
                                    local reloadEvent = tool:FindFirstChild("Reload") or tool:FindFirstChild("ReloadEvent")
                                    if reloadEvent and reloadEvent:IsA("RemoteEvent") then
                                        reloadEvent:FireServer()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Kill All button
    -- Triggered via Settings["arsenal"]["Kill All"] = true
    addConnection("arsenal_killall", RunService.Heartbeat:Connect(function()
        local gs = Settings["arsenal"] or {}
        if not gs["Kill All"] then return end
        gs["Kill All"] = false
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if isEnemy(player) and player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
        end)
        notify("Arsenal", "Kill All triggered!")
    end))
    
    -- Rapid Fire
    addConnection("arsenal_rapid", RunService.Heartbeat:Connect(function()
        local gs = Settings["arsenal"] or {}
        if not gs["Rapid Fire"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in pairs(tool:GetDescendants()) do
                            local n = string.lower(v.Name)
                            if (v:IsA("NumberValue") or v:IsA("IntValue")) then
                                if n:find("firerate") or n:find("fire_rate") or n:find("cooldown") or n:find("delay") then
                                    local mult = gs["Fire Rate Multiplier"] or 2
                                    v.Value = v.Value / mult
                                end
                            end
                        end
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: RIVALS
-- ============================================

local function initRivals()
    notify("Script Hub", "Rivals module loaded!")
    
    -- Instant Ability (no cooldown)
    addConnection("rivals_ability", RunService.Heartbeat:Connect(function()
        local gs = Settings["rivals"] or {}
        if not gs["Instant Ability"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    local n = string.lower(v.Name)
                    if (v:IsA("NumberValue") or v:IsA("IntValue")) and (n:find("cooldown") or n:find("ability") and n:find("timer")) then
                        v.Value = 0
                    end
                end
            end
            -- Also check PlayerGui for cooldown UI
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, v in pairs(pgui:GetDescendants()) do
                    if v:IsA("NumberValue") and string.lower(v.Name):find("cooldown") then
                        v.Value = 0
                    end
                end
            end
        end)
    end))
    
    -- Bomb ESP
    addConnection("rivals_bombesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["rivals"] or {}
        if not gs["Bomb ESP"] then
            -- Remove bomb ESP if exists
            local bombHL = workspace:FindFirstChild("BombESPHighlight")
            if bombHL then bombHL:Destroy() end
            return
        end
        pcall(function()
            -- Search workspace for bomb/objective
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("BasePart") and (n:find("bomb") or n:find("spike") or n:find("objective")) then
                    if not obj:FindFirstChild("BombESPBB") then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "BombESPBB"
                        bb.Adornee = obj
                        bb.Size = UDim2.new(0, 100, 0, 30)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = obj
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 165, 0)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 14
                        label.Text = "💣 BOMB"
                        label.Parent = bb
                        
                        local hl = Instance.new("Highlight")
                        hl.Name = "BombESPHighlight"
                        hl.FillColor = Color3.fromRGB(255, 165, 0)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                        hl.Parent = obj
                    end
                end
            end
        end)
    end))
    
    -- Auto Plant/Defuse
    addConnection("rivals_autoplant", RunService.Heartbeat:Connect(function()
        local gs = Settings["rivals"] or {}
        if not gs["Auto Plant/Defuse"] then return end
        pcall(function()
            -- Look for interact prompts related to bomb
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local n = string.lower(v.Name)
                    if n:find("plant") or n:find("defuse") or n:find("bomb") then
                        local hrp = getHRP()
                        if hrp and v.Parent and v.Parent:IsA("BasePart") then
                            local dist = (hrp.Position - v.Parent.Position).Magnitude
                            if dist < v.MaxActivationDistance + 5 then
                                fireproximityprompt(v, 1)
                            end
                        end
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: HYPERSHOT
-- ============================================

local function initHypershot()
    notify("Script Hub", "Hypershot module loaded!")
    
    -- Infinite Dash
    addConnection("hypershot_dash", RunService.Heartbeat:Connect(function()
        local gs = Settings["hypershot"] or {}
        if not gs["Infinite Dash"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    local n = string.lower(v.Name)
                    if (v:IsA("NumberValue") or v:IsA("IntValue")) and (n:find("dash") or n:find("cooldown") or n:find("stamina")) then
                        if n:find("cooldown") then v.Value = 0
                        elseif n:find("stamina") or n:find("dash") then v.Value = 999 end
                    end
                end
            end
        end)
    end))
    
    -- Instant Charge
    addConnection("hypershot_charge", RunService.Heartbeat:Connect(function()
        local gs = Settings["hypershot"] or {}
        if not gs["Instant Charge"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in pairs(tool:GetDescendants()) do
                            local n = string.lower(v.Name)
                            if (v:IsA("NumberValue")) and (n:find("charge") or n:find("power")) then
                                v.Value = v.Value + 100
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Pickup ESP
    addConnection("hypershot_pickupesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["hypershot"] or {}
        if not (gs["Pickup ESP"] or gs["Power-Up ESP"]) then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    local isPickup = n:find("pickup") or n:find("health") or n:find("ammo") or n:find("weapon")
                    local isPowerUp = n:find("power") or n:find("boost") or n:find("buff")
                    
                    if (gs["Pickup ESP"] and isPickup) or (gs["Power-Up ESP"] and isPowerUp) then
                        if not obj:FindFirstChild("PickupHL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "PickupHL"
                            hl.FillColor = isPowerUp and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 200, 255)
                            hl.FillTransparency = 0.3
                            hl.Parent = obj
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Pickup
    addConnection("hypershot_autopickup", RunService.Heartbeat:Connect(function()
        local gs = Settings["hypershot"] or {}
        if not gs["Auto Pickup"] then return end
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if n:find("pickup") or n:find("collectible") then
                        if (obj.Position - hrp.Position).Magnitude < 50 then
                            -- Touch the pickup
                            firetouchinterest(hrp, obj, 0)
                            task.wait()
                            firetouchinterest(hrp, obj, 1)
                        end
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: JAILBREAK
-- ============================================

local function initJailbreak()
    notify("Script Hub", "Jailbreak module loaded!")
    
    -- Robbery locations
    local RobberyLocations = {
        Bank = nil,
        JewelryStore = nil,
        Museum = nil,
        PowerPlant = nil,
        Casino = nil,
        CriminalBase = nil,
        PoliceStation = nil,
        Garage = nil
    }
    
    -- Find robbery locations
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            local n = string.lower(obj.Name)
            if obj:IsA("BasePart") or obj:IsA("Model") then
                if n:find("bank") then RobberyLocations.Bank = obj
                elseif n:find("jewel") then RobberyLocations.JewelryStore = obj
                elseif n:find("museum") then RobberyLocations.Museum = obj
                elseif n:find("power") or n:find("plant") then RobberyLocations.PowerPlant = obj
                elseif n:find("casino") then RobberyLocations.Casino = obj
                elseif n:find("criminal") and n:find("base") then RobberyLocations.CriminalBase = obj
                elseif n:find("police") and n:find("station") then RobberyLocations.PoliceStation = obj
                elseif n:find("garage") then RobberyLocations.Garage = obj
                end
            end
        end
    end)
    
    -- Teleport buttons
    addConnection("jb_teleport", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        for btnName, loc in pairs({
            ["Teleport to Bank"] = RobberyLocations.Bank,
            ["Teleport to Jewelry Store"] = RobberyLocations.JewelryStore,
            ["Teleport to Museum"] = RobberyLocations.Museum,
            ["Teleport to Power Plant"] = RobberyLocations.PowerPlant,
            ["Teleport to Casino"] = RobberyLocations.Casino,
            ["Teleport to Criminal Base"] = RobberyLocations.CriminalBase,
            ["Teleport to Police Station"] = RobberyLocations.PoliceStation,
            ["Teleport to Garage"] = RobberyLocations.Garage,
        }) do
            if gs[btnName] then
                gs[btnName] = false
                if loc then
                    local pos = loc:IsA("Model") and loc:GetBoundingBox().Position or loc.Position
                    teleportTo(pos + Vector3.new(0, 5, 0))
                    notify("Jailbreak", "Teleported to " .. btnName:gsub("Teleport to ", ""))
                else
                    notify("Jailbreak", "Location not found: " .. btnName:gsub("Teleport to ", ""))
                end
            end
        end
    end))
    
    -- Infinite Nitro
    addConnection("jb_nitro", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        if not gs["Infinite Nitro"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                local seat = char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").SeatPart
                if seat then
                    local vehicle = seat.Parent
                    for _, v in pairs(vehicle:GetDescendants()) do
                        local n = string.lower(v.Name)
                        if (v:IsA("NumberValue") or v:IsA("IntValue")) and (n:find("nitro") or n:find("boost") or n:find("fuel")) then
                            v.Value = 999
                        end
                    end
                end
            end
        end)
    end))
    
    -- Vehicle Speed
    addConnection("jb_vspeed", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        local mult = gs["Vehicle Speed Multiplier"]
        if not mult or mult <= 1 then return end
        pcall(function()
            local char = getCharacter()
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart then
                    local vehicle = hum.SeatPart.Parent
                    for _, v in pairs(vehicle:GetDescendants()) do
                        local n = string.lower(v.Name)
                        if v:IsA("VehicleSeat") then
                            v.MaxSpeed = v.MaxSpeed * mult
                            v.Torque = v.Torque * mult
                        end
                    end
                end
            end
        end)
    end))
    
    -- Vehicle Fly
    addConnection("jb_vfly", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        if not gs["Vehicle Fly"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart then
                    local seat = hum.SeatPart
                    if not seat:FindFirstChild("JBFlyBV") then
                        local bv = Instance.new("BodyVelocity")
                        bv.Name = "JBFlyBV"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.zero
                        bv.Parent = seat
                    end
                    local bv = seat:FindFirstChild("JBFlyBV")
                    if bv then
                        local dir = Vector3.zero
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end
                        bv.Velocity = dir.Magnitude > 0 and dir.Unit * 100 or Vector3.zero
                    end
                end
            end
        end)
    end))
    
    -- Auto Rob
    addConnection("jb_autorob", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        if not gs["Auto Rob"] then return end
        pcall(function()
            -- Interact with robbery proximity prompts
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local n = string.lower(v.Name)
                    if n:find("rob") or n:find("steal") or n:find("collect") or n:find("grab") then
                        local hrp = getHRP()
                        if hrp and v.Parent:IsA("BasePart") then
                            local dist = (hrp.Position - v.Parent.Position).Magnitude
                            if dist < v.MaxActivationDistance + 5 then
                                fireproximityprompt(v, 1)
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Arrest
    addConnection("jb_autoarrest", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        if not gs["Auto Arrest"] then return end
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if phrp and (hrp.Position - phrp.Position).Magnitude < 20 then
                        -- Try to fire arrest remote
                        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and string.lower(remote.Name):find("arrest") then
                                remote:FireServer(player)
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Remove Doors
    addConnection("jb_doors", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        if not gs["Remove All Doors"] then return end
        gs["Remove All Doors"] = false
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("BasePart") and (n:find("door") or n:find("gate") or n:find("bars")) then
                    obj:Destroy()
                end
            end
        end)
        notify("Jailbreak", "Doors removed!")
    end))
    
    -- Robbery Status ESP
    addConnection("jb_robesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["jailbreak"] or {}
        if not gs["ESP Robbery Status"] then return end
        pcall(function()
            for locName, loc in pairs(RobberyLocations) do
                if loc then
                    local part = loc:IsA("Model") and loc.PrimaryPart or loc
                    if part and not part:FindFirstChild("RobStatusBB") then
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "RobStatusBB"
                        bb.Adornee = part
                        bb.Size = UDim2.new(0, 120, 0, 30)
                        bb.StudsOffset = Vector3.new(0, 10, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = part
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(0, 255, 100)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 14
                        label.Text = "📍 " .. locName
                        label.Parent = bb
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: COMBAT ARENA
-- ============================================

local function initCombatArena()
    notify("Script Hub", "Combat Arena module loaded!")
    
    -- Auto Parry
    addConnection("ca_parry", RunService.Heartbeat:Connect(function()
        local gs = Settings["combat-arena"] or {}
        if not gs["Auto Parry"] then return end
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, player in pairs(Players:GetPlayers()) do
                if isEnemy(player) and player.Character then
                    local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if phrp and (phrp.Position - hrp.Position).Magnitude < 15 then
                        -- Check if they're attacking (animation state)
                        local hum = player.Character:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local animator = hum:FindFirstChildOfClass("Animator")
                            if animator then
                                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                    local n = string.lower(track.Name)
                                    if n:find("attack") or n:find("swing") or n:find("slash") then
                                        -- Fire parry
                                        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                            if remote:IsA("RemoteEvent") and string.lower(remote.Name):find("parry") or string.lower(remote.Name):find("block") then
                                                remote:FireServer()
                                            end
                                        end
                                        pcall(mouse1click)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Kill Aura
    addConnection("ca_killaura", RunService.Heartbeat:Connect(function()
        local gs = Settings["combat-arena"] or {}
        if not gs["Kill Aura"] then return end
        local range = gs["Kill Aura Range"] or 15
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, player in pairs(Players:GetPlayers()) do
                if isEnemy(player) and player.Character then
                    local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                    local phum = player.Character:FindFirstChildOfClass("Humanoid")
                    if phrp and phum and (phrp.Position - hrp.Position).Magnitude < range then
                        phum:TakeDamage(10)
                    end
                end
            end
        end)
    end))
    
    -- Auto Combo
    addConnection("ca_combo", RunService.Heartbeat:Connect(function()
        local gs = Settings["combat-arena"] or {}
        if not gs["Auto Combo"] then return end
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            local target = getClosestEnemy(15)
            if target and target.Character then
                local phrp = target.Character:FindFirstChild("HumanoidRootPart")
                if phrp then
                    -- Face target and click rapidly
                    hrp.CFrame = CFrame.new(hrp.Position, phrp.Position)
                    pcall(mouse1click)
                end
            end
        end)
    end))
    
    -- Auto Block
    addConnection("ca_block", RunService.Heartbeat:Connect(function()
        local gs = Settings["combat-arena"] or {}
        if not gs["Auto Block"] then return end
        pcall(function()
            -- Block when not attacking
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and string.lower(remote.Name):find("block") then
                    remote:FireServer(true)
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: STEAL A BRAINROT
-- ============================================

local function initStealABrainrot()
    notify("Script Hub", "Steal a Brainrot module loaded!")
    
    -- Auto Collect
    addConnection("sab_collect", RunService.Heartbeat:Connect(function()
        local gs = Settings["steal-a-brainrot"] or {}
        if not gs["Auto Collect"] then return end
        local range = gs["Collect Range"] or 20
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local n = string.lower(obj.Name)
                    if n:find("brainrot") or n:find("item") or n:find("collect") or n:find("pickup") then
                        local pos = obj:IsA("Model") and obj:GetBoundingBox().Position or obj.Position
                        if (pos - hrp.Position).Magnitude < range then
                            local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
                            if part then
                                firetouchinterest(hrp, part, 0)
                                task.wait()
                                firetouchinterest(hrp, part, 1)
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Teleport to Items
    addConnection("sab_tpitems", RunService.Heartbeat:Connect(function()
        local gs = Settings["steal-a-brainrot"] or {}
        if not gs["Teleport to Items"] then return end
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            local closest = nil
            local closestDist = math.huge
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if n:find("brainrot") or n:find("item") or n:find("collect") then
                        local dist = (obj.Position - hrp.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = obj
                        end
                    end
                end
            end
            if closest then
                teleportTo(closest.Position + Vector3.new(0, 3, 0))
            end
        end)
    end))
    
    -- Item ESP
    addConnection("sab_itemesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["steal-a-brainrot"] or {}
        if not (gs["Item ESP"] or gs["Rare Item ESP"]) then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if n:find("brainrot") or n:find("item") or n:find("collect") then
                        if not obj:FindFirstChild("ItemHL") then
                            local isRare = n:find("rare") or n:find("legend") or n:find("epic") or n:find("mythic")
                            local hl = Instance.new("Highlight")
                            hl.Name = "ItemHL"
                            hl.FillColor = isRare and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(0, 255, 200)
                            hl.FillTransparency = isRare and 0.2 or 0.5
                            hl.Parent = obj
                        end
                    end
                end
            end
        end)
    end))
    
    -- Farm Loop
    addConnection("sab_farmloop", RunService.Heartbeat:Connect(function()
        local gs = Settings["steal-a-brainrot"] or {}
        if not gs["Farm Loop"] then return end
        gs["Auto Collect"] = true
        gs["Teleport to Items"] = true
        gs["Auto Store"] = true
    end))
    
    -- Teleport buttons
    addConnection("sab_tp", RunService.Heartbeat:Connect(function()
        local gs = Settings["steal-a-brainrot"] or {}
        if gs["Teleport to Nearest Item"] then
            gs["Teleport to Nearest Item"] = false
            pcall(function()
                local hrp = getHRP()
                if not hrp then return end
                local closest, closestDist = nil, math.huge
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.lower(obj.Name):find("brainrot") then
                        local d = (obj.Position - hrp.Position).Magnitude
                        if d < closestDist then closestDist = d; closest = obj end
                    end
                end
                if closest then teleportTo(closest.Position + Vector3.new(0, 3, 0)) end
            end)
        end
        if gs["Teleport to Safe Zone"] then
            gs["Teleport to Safe Zone"] = false
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.lower(obj.Name):find("safe") then
                        teleportTo(obj.Position + Vector3.new(0, 3, 0))
                        break
                    end
                end
            end)
        end
    end))
end

-- ============================================
-- GAME-SPECIFIC: MURDER MYSTERY 2
-- ============================================

local function initMurderMystery2()
    notify("Script Hub", "Murder Mystery 2 module loaded!")
    
    local MurdererPlayer = nil
    local SheriffPlayer = nil
    
    -- Role Detection
    local function detectRoles()
        MurdererPlayer = nil
        SheriffPlayer = nil
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    -- Check for knife (murderer) or gun (sheriff)
                    for _, item in pairs(player.Character:GetChildren()) do
                        if item:IsA("Tool") then
                            local n = string.lower(item.Name)
                            if n:find("knife") or n:find("blade") then
                                MurdererPlayer = player
                            elseif n:find("gun") or n:find("revolver") or n:find("pistol") then
                                SheriffPlayer = player
                            end
                        end
                    end
                    -- Check backpack too
                    if player:FindFirstChild("Backpack") then
                        for _, item in pairs(player.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                local n = string.lower(item.Name)
                                if n:find("knife") or n:find("blade") then
                                    MurdererPlayer = player
                                elseif n:find("gun") or n:find("revolver") or n:find("pistol") then
                                    SheriffPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    addConnection("mm2_roles", RunService.Heartbeat:Connect(function()
        detectRoles()
        local gs = Settings["murder-mystery-2"] or {}
        
        -- Update ESP colors for murderer/sheriff
        if gs["Murderer ESP"] or gs["Sheriff ESP"] or gs["Role Reveal"] then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local bb = head:FindFirstChild("RoleTag")
                        if not bb then
                            bb = Instance.new("BillboardGui")
                            bb.Name = "RoleTag"
                            bb.Adornee = head
                            bb.Size = UDim2.new(0, 150, 0, 25)
                            bb.StudsOffset = Vector3.new(0, 2.5, 0)
                            bb.AlwaysOnTop = true
                            bb.Parent = head
                            
                            local label = Instance.new("TextLabel")
                            label.Name = "RoleLabel"
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextStrokeTransparency = 0
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 14
                            label.Parent = bb
                        end
                        
                        local label = bb:FindFirstChild("RoleLabel")
                        if label then
                            if player == MurdererPlayer then
                                label.Text = "🔪 MURDERER"
                                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                                bb.Enabled = gs["Murderer ESP"] or gs["Role Reveal"] or false
                            elseif player == SheriffPlayer then
                                label.Text = "🔫 SHERIFF"
                                label.TextColor3 = Color3.fromRGB(0, 100, 255)
                                bb.Enabled = gs["Sheriff ESP"] or gs["Role Reveal"] or false
                            else
                                label.Text = "👤 Innocent"
                                label.TextColor3 = Color3.fromRGB(0, 255, 0)
                                bb.Enabled = gs["Role Reveal"] or false
                            end
                        end
                    end
                end
            end
        end
        
        -- Murderer Alert
        if gs["Murderer Alert"] and MurdererPlayer and MurdererPlayer.Character then
            local myHRP = getHRP()
            local mHRP = MurdererPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and mHRP then
                local dist = (myHRP.Position - mHRP.Position).Magnitude
                local alertDist = gs["Alert Distance"] or 30
                if dist < alertDist then
                    -- Flash screen warning
                    notify("⚠️ DANGER", "Murderer is " .. math.floor(dist) .. " studs away!", 1)
                end
            end
        end
    end))
    
    -- Coin ESP
    addConnection("mm2_coinesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["murder-mystery-2"] or {}
        if not gs["Coin ESP"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("BasePart") and (n:find("coin") or n:find("shard") or n:find("collectible")) then
                    if not obj:FindFirstChild("CoinHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "CoinHL"
                        hl.FillColor = Color3.fromRGB(255, 255, 0)
                        hl.FillTransparency = 0.3
                        hl.OutlineColor = Color3.fromRGB(255, 215, 0)
                        hl.Parent = obj
                    end
                end
            end
        end)
    end))
    
    -- Auto Collect Coins
    addConnection("mm2_autocoin", RunService.Heartbeat:Connect(function()
        local gs = Settings["murder-mystery-2"] or {}
        if not gs["Auto Collect Coins"] then return end
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("BasePart") and (n:find("coin") or n:find("shard")) then
                    firetouchinterest(hrp, obj, 0)
                    task.wait()
                    firetouchinterest(hrp, obj, 1)
                end
            end
        end)
    end))
    
    -- Auto Grab Gun
    addConnection("mm2_autogun", RunService.Heartbeat:Connect(function()
        local gs = Settings["murder-mystery-2"] or {}
        if not gs["Auto Grab Gun"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") then
                    local n = string.lower(obj.Name)
                    if n:find("gun") or n:find("revolver") or n:find("pistol") then
                        local hrp = getHRP()
                        if hrp and obj:FindFirstChild("Handle") then
                            hrp.CFrame = obj.Handle.CFrame
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Shoot Murderer (as sheriff)
    addConnection("mm2_autoshoot", RunService.Heartbeat:Connect(function()
        local gs = Settings["murder-mystery-2"] or {}
        if not gs["Auto Shoot Murderer"] then return end
        if not MurdererPlayer or not isAlive(MurdererPlayer) then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") and (string.lower(tool.Name):find("gun") or string.lower(tool.Name):find("revolver")) then
                        local part = MurdererPlayer.Character:FindFirstChild("Head") or MurdererPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if part then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
                            pcall(mouse1click)
                        end
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: BLADE BALL
-- ============================================

local function initBladeBall()
    notify("Script Hub", "Blade Ball module loaded!")
    
    local BallObject = nil
    
    -- Find the ball
    local function findBall()
        for _, obj in pairs(workspace:GetDescendants()) do
            local n = string.lower(obj.Name)
            if obj:IsA("BasePart") and (n:find("ball") or n:find("blade") or n:find("projectile")) then
                BallObject = obj
                return obj
            end
        end
        return nil
    end
    
    -- Auto Parry
    addConnection("bb_autoparry", RunService.Heartbeat:Connect(function()
        local gs = Settings["blade-ball"] or {}
        if not gs["Auto Parry"] then return end
        
        local ball = BallObject or findBall()
        if not ball then return end
        
        local hrp = getHRP()
        if not hrp then return end
        
        local dist = (ball.Position - hrp.Position).Magnitude
        local velocity = ball.Velocity or ball.AssemblyLinearVelocity or Vector3.zero
        local speed = velocity.Magnitude
        
        -- Calculate time to impact
        local timeToImpact = dist / math.max(speed, 1)
        local offset = (gs["Parry Timing Offset"] or 50) / 1000
        
        -- Check if ball is heading towards us
        local dirToBall = (hrp.Position - ball.Position).Unit
        local ballDir = velocity.Magnitude > 0 and velocity.Unit or Vector3.zero
        local dot = dirToBall:Dot(ballDir)
        
        if dot > 0.5 and timeToImpact < 0.5 + offset then
            -- Trigger parry/click
            pcall(function()
                -- Find parry remote
                for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        local n = string.lower(remote.Name)
                        if n:find("parry") or n:find("deflect") or n:find("block") or n:find("swing") or n:find("click") then
                            remote:FireServer()
                        end
                    end
                end
                -- Also simulate click
                pcall(mouse1click)
            end)
        end
    end))
    
    -- Ball ESP
    addConnection("bb_ballesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["blade-ball"] or {}
        local ball = BallObject or findBall()
        if not ball then return end
        
        if gs["Ball ESP"] then
            if not ball:FindFirstChild("BallHL") then
                local hl = Instance.new("Highlight")
                hl.Name = "BallHL"
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0
                hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                hl.Parent = ball
            end
        else
            local hl = ball:FindFirstChild("BallHL")
            if hl then hl:Destroy() end
        end
        
        -- Ball Speed Prediction (trajectory line)
        if gs["Ball Speed Prediction"] then
            local velocity = ball.Velocity or ball.AssemblyLinearVelocity or Vector3.zero
            if velocity.Magnitude > 1 then
                -- Create/update beam showing trajectory
                -- Using a simple part for visualization
                local trajPart = workspace:FindFirstChild("BallTrajectory")
                if not trajPart then
                    trajPart = Instance.new("Part")
                    trajPart.Name = "BallTrajectory"
                    trajPart.Anchored = true
                    trajPart.CanCollide = false
                    trajPart.Material = Enum.Material.Neon
                    trajPart.Color = Color3.fromRGB(255, 255, 0)
                    trajPart.Transparency = 0.5
                    trajPart.Size = Vector3.new(0.2, 0.2, 50)
                    trajPart.Parent = workspace
                end
                trajPart.CFrame = CFrame.new(ball.Position, ball.Position + velocity.Unit) * CFrame.new(0, 0, -25)
            end
        end
    end))
    
    -- Target ESP
    addConnection("bb_targetesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["blade-ball"] or {}
        if not gs["Target ESP"] then return end
        
        local ball = BallObject or findBall()
        if not ball then return end
        
        -- Determine who ball is targeting based on velocity direction
        local velocity = ball.Velocity or ball.AssemblyLinearVelocity or Vector3.zero
        if velocity.Magnitude < 1 then return end
        
        local ballDir = velocity.Unit
        local bestDot = -1
        local target = nil
        
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                if phrp then
                    local dirToPlayer = (phrp.Position - ball.Position).Unit
                    local dot = ballDir:Dot(dirToPlayer)
                    if dot > bestDot then
                        bestDot = dot
                        target = player
                    end
                end
            end
        end
        
        -- Highlight target
        if target and target.Character then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("TargetHL")
                    if hl then hl:Destroy() end
                end
            end
            if not target.Character:FindFirstChild("TargetHL") then
                local hl = Instance.new("Highlight")
                hl.Name = "TargetHL"
                hl.FillColor = Color3.fromRGB(255, 100, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                hl.Parent = target.Character
            end
        end
    end))
    
    -- Auto Equip Best Sword
    addConnection("bb_equip", RunService.Heartbeat:Connect(function()
        local gs = Settings["blade-ball"] or {}
        if not gs["Auto Equip Best Sword"] then return end
        pcall(function()
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                local bestTool = nil
                local bestVal = 0
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        local val = tool:FindFirstChild("Rarity") or tool:FindFirstChild("Tier") or tool:FindFirstChild("Level")
                        local v = val and val.Value or 0
                        if v > bestVal then
                            bestVal = v
                            bestTool = tool
                        end
                    end
                end
                if bestTool then
                    local hum = getHumanoid()
                    if hum then hum:EquipTool(bestTool) end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: TOWER OF HELL
-- ============================================

local function initTowerOfHell()
    notify("Script Hub", "Tower of Hell module loaded!")
    
    -- Find tower top
    local function findTowerTop()
        local highest = nil
        local highestY = -math.huge
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if (n:find("finish") or n:find("win") or n:find("top") or n:find("goal")) then
                        if obj.Position.Y > highestY then
                            highestY = obj.Position.Y
                            highest = obj
                        end
                    end
                end
            end
            -- If no finish found, find highest part
            if not highest then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Position.Y > highestY then
                        highestY = obj.Position.Y
                        highest = obj
                    end
                end
            end
        end)
        return highest
    end
    
    -- Teleport to Top
    addConnection("toh_top", RunService.Heartbeat:Connect(function()
        local gs = Settings["tower-of-hell"] or {}
        if not gs["Teleport to Top"] then return end
        gs["Teleport to Top"] = false
        local top = findTowerTop()
        if top then
            teleportTo(top.Position + Vector3.new(0, 5, 0))
            notify("Tower of Hell", "Teleported to top!")
        else
            notify("Tower of Hell", "Could not find tower top")
        end
    end))
    
    -- Auto Win
    addConnection("toh_autowin", RunService.Heartbeat:Connect(function()
        local gs = Settings["tower-of-hell"] or {}
        if not gs["Auto Win"] then return end
        gs["Auto Win"] = false
        local top = findTowerTop()
        if top then
            teleportTo(top.Position + Vector3.new(0, 3, 0))
            -- Touch the finish
            local hrp = getHRP()
            if hrp then
                pcall(function()
                    firetouchinterest(hrp, top, 0)
                    task.wait(0.1)
                    firetouchinterest(hrp, top, 1)
                end)
            end
            notify("Tower of Hell", "Auto-win triggered!")
        end
    end))
    
    -- Remove Kill Bricks
    addConnection("toh_killbricks", RunService.Heartbeat:Connect(function()
        local gs = Settings["tower-of-hell"] or {}
        if not gs["Remove Kill Bricks"] then return end
        gs["Remove Kill Bricks"] = false
        local count = 0
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    -- Kill bricks are usually red, have scripts, or touch connections
                    local n = string.lower(obj.Name)
                    if n:find("kill") or n:find("lava") or n:find("danger") or 
                       obj.Color == Color3.fromRGB(255, 0, 0) or
                       obj.BrickColor == BrickColor.new("Really red") then
                        -- Check if it has a kill script
                        local hasKill = false
                        for _, child in pairs(obj:GetChildren()) do
                            if child:IsA("Script") or child:IsA("LocalScript") then
                                hasKill = true
                            end
                        end
                        if hasKill or n:find("kill") then
                            obj:Destroy()
                            count = count + 1
                        end
                    end
                end
            end
        end)
        notify("Tower of Hell", count .. " kill bricks removed!")
    end))
    
    -- Remove Spinners/Obstacles
    addConnection("toh_spinners", RunService.Heartbeat:Connect(function()
        local gs = Settings["tower-of-hell"] or {}
        if gs["Remove Spinners"] then
            gs["Remove Spinners"] = false
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    local n = string.lower(obj.Name)
                    if n:find("spin") or n:find("rotat") or n:find("swing") then
                        obj:Destroy()
                    end
                end
            end)
            notify("Tower of Hell", "Spinners removed!")
        end
        
        if gs["Remove All Obstacles"] then
            gs["Remove All Obstacles"] = false
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = string.lower(obj.Name)
                        if n:find("kill") or n:find("spin") or n:find("lava") or n:find("danger") or n:find("obstacle") then
                            obj:Destroy()
                        end
                    end
                end
            end)
            notify("Tower of Hell", "All obstacles removed!")
        end
    end))
    
    -- Highlight Kill Bricks
    addConnection("toh_hlkill", RunService.Heartbeat:Connect(function()
        local gs = Settings["tower-of-hell"] or {}
        if not gs["Highlight Kill Bricks"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if (n:find("kill") or n:find("lava") or n:find("danger")) and not obj:FindFirstChild("KillHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "KillHL"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.FillTransparency = 0.3
                        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                        hl.Parent = obj
                    end
                end
            end
        end)
    end))
    
    -- Path Finder (highlight safe platforms)
    addConnection("toh_path", RunService.Heartbeat:Connect(function()
        local gs = Settings["tower-of-hell"] or {}
        if not gs["Highlight Safe Platforms"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CanCollide then
                    local n = string.lower(obj.Name)
                    local isDanger = n:find("kill") or n:find("lava") or n:find("danger")
                    if not isDanger and not obj:FindFirstChild("SafeHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "SafeHL"
                        hl.FillColor = Color3.fromRGB(0, 255, 100)
                        hl.FillTransparency = 0.8
                        hl.OutlineColor = Color3.fromRGB(0, 200, 50)
                        hl.OutlineTransparency = 0.5
                        hl.Parent = obj
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: DA HOOD
-- ============================================

local function initDaHood()
    notify("Script Hub", "Da Hood module loaded!")
    
    -- Auto Stomp
    addConnection("dh_stomp", RunService.Heartbeat:Connect(function()
        local gs = Settings["da-hood"] or {}
        if not (gs["Auto Stomp"] or gs["Stomp Aura"]) then return end
        
        local hrp = getHRP()
        if not hrp then return end
        local range = gs["Stomp Range"] or 15
        
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hum and phrp then
                        -- Check if player is knocked/ragdolled
                        local isKnocked = hum.Health > 0 and (
                            hum:GetState() == Enum.HumanoidStateType.Ragdoll or
                            hum:GetState() == Enum.HumanoidStateType.FallingDown or
                            hum:GetState() == Enum.HumanoidStateType.PlatformStanding
                        )
                        
                        if isKnocked and (phrp.Position - hrp.Position).Magnitude < range then
                            -- Fire stomp remote
                            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                if remote:IsA("RemoteEvent") then
                                    local n = string.lower(remote.Name)
                                    if n:find("stomp") or n:find("finish") or n:find("execute") then
                                        remote:FireServer(player)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Cash ESP
    addConnection("dh_cashesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["da-hood"] or {}
        if not gs["Cash ESP"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("BasePart") and (n:find("cash") or n:find("money") or n:find("dollar")) then
                    if not obj:FindFirstChild("CashHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "CashHL"
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.FillTransparency = 0.3
                        hl.Parent = obj
                        
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "CashBB"
                        bb.Adornee = obj
                        bb.Size = UDim2.new(0, 80, 0, 20)
                        bb.StudsOffset = Vector3.new(0, 2, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = obj
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(0, 255, 0)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 12
                        label.Text = "💰 Cash"
                        label.Parent = bb
                    end
                end
            end
        end)
    end))
    
    -- Teleport buttons
    addConnection("dh_teleport", RunService.Heartbeat:Connect(function()
        local gs = Settings["da-hood"] or {}
        
        if gs["Teleport to ATM"] then
            gs["Teleport to ATM"] = false
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.lower(obj.Name):find("atm") then
                        teleportTo(obj.Position + Vector3.new(0, 3, 0))
                        notify("Da Hood", "Teleported to ATM!")
                        break
                    end
                end
            end)
        end
        
        if gs["Teleport to Gun Shop"] then
            gs["Teleport to Gun Shop"] = false
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    local n = string.lower(obj.Name)
                    if obj:IsA("BasePart") and (n:find("gun") and n:find("shop") or n:find("gunstore")) then
                        teleportTo(obj.Position + Vector3.new(0, 3, 0))
                        notify("Da Hood", "Teleported to Gun Shop!")
                        break
                    end
                end
            end)
        end
    end))
    
    -- Auto Carry & Throw
    addConnection("dh_carry", RunService.Heartbeat:Connect(function()
        local gs = Settings["da-hood"] or {}
        if not gs["Auto Carry & Throw"] then return end
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local n = string.lower(remote.Name)
                    if n:find("carry") or n:find("pickup") or n:find("grab") then
                        -- Find nearest knocked player
                        local hrp = getHRP()
                        if hrp then
                            for _, player in pairs(Players:GetPlayers()) do
                                if player ~= LocalPlayer and player.Character then
                                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                                    local phrp = player.Character:FindFirstChild("HumanoidRootPart")
                                    if hum and phrp and hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                                        if (phrp.Position - hrp.Position).Magnitude < 10 then
                                            remote:FireServer(player)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: NATURAL DISASTER SURVIVAL
-- ============================================

local function initNaturalDisasterSurvival()
    notify("Script Hub", "Natural Disaster Survival module loaded!")
    
    -- Disaster prediction
    addConnection("nds_predict", RunService.Heartbeat:Connect(function()
        local gs = Settings["natural-disaster-survival"] or {}
        if not gs["Disaster Prediction"] then return end
        pcall(function()
            -- Check for disaster-related objects/values
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("StringValue") and (n:find("disaster") or n:find("current") or n:find("event")) then
                    -- Display on screen
                    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                    if pgui then
                        local screen = pgui:FindFirstChild("DisasterPredict")
                        if not screen then
                            screen = Instance.new("ScreenGui")
                            screen.Name = "DisasterPredict"
                            screen.Parent = pgui
                            
                            local label = Instance.new("TextLabel")
                            label.Name = "PredLabel"
                            label.Size = UDim2.new(0, 300, 0, 40)
                            label.Position = UDim2.new(0.5, -150, 0, 10)
                            label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                            label.BackgroundTransparency = 0.3
                            label.TextColor3 = Color3.fromRGB(255, 200, 0)
                            label.Font = Enum.Font.GothamBold
                            label.TextSize = 16
                            label.Parent = screen
                        end
                        local label = screen:FindFirstChild("PredLabel")
                        if label then
                            label.Text = "⚠️ Next: " .. obj.Value
                        end
                    end
                end
            end
        end)
    end))
    
    -- Anti Fire
    addConnection("nds_antifire", RunService.Heartbeat:Connect(function()
        local gs = Settings["natural-disaster-survival"] or {}
        if not gs["Anti Fire"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, obj in pairs(char:GetDescendants()) do
                    local n = string.lower(obj.Name)
                    if obj:IsA("Fire") or (n:find("fire") and obj:IsA("ParticleEmitter")) then
                        obj:Destroy()
                    end
                end
            end
        end)
    end))
    
    -- Anchor Character (prevent push from wind/waves)
    addConnection("nds_anchor", RunService.Heartbeat:Connect(function()
        local gs = Settings["natural-disaster-survival"] or {}
        if not gs["Anchor Character"] then return end
        local hrp = getHRP()
        if hrp then
            -- Counter external velocities
            hrp.AssemblyLinearVelocity = Vector3.new(0, math.min(hrp.AssemblyLinearVelocity.Y, 0), 0)
        end
    end))
    
    -- No Fall Damage
    addConnection("nds_nofall", RunService.Heartbeat:Connect(function()
        local gs = Settings["natural-disaster-survival"] or {}
        if not gs["No Fall Damage"] then return end
        local hum = getHumanoid()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end))
    
    -- Auto Safe Spot
    addConnection("nds_safespot", RunService.Heartbeat:Connect(function()
        local gs = Settings["natural-disaster-survival"] or {}
        if not gs["Auto Safe Spot"] then return end
        pcall(function()
            -- Find highest enclosed point for most disasters
            local hrp = getHRP()
            if not hrp then return end
            
            local bestSpot = nil
            local bestScore = -math.huge
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CanCollide and obj.Size.X > 4 and obj.Size.Z > 4 then
                    local n = string.lower(obj.Name)
                    if not (n:find("kill") or n:find("danger") or n:find("lava")) then
                        -- Score based on height and whether there's cover above
                        local score = obj.Position.Y
                        -- Check for roof
                        local ray = workspace:Raycast(obj.Position + Vector3.new(0, 1, 0), Vector3.new(0, 50, 0))
                        if ray then score = score + 100 end -- enclosed = safer
                        
                        if score > bestScore then
                            bestScore = score
                            bestSpot = obj
                        end
                    end
                end
            end
            
            if bestSpot then
                teleportTo(bestSpot.Position + Vector3.new(0, 5, 0))
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: ONE TAP
-- ============================================

local function initOneTap()
    notify("Script Hub", "One Tap module loaded!")
    -- Uses shared aimbot/ESP systems
    -- Quickscope Assist
    addConnection("ot_quickscope", RunService.Heartbeat:Connect(function()
        local gs = Settings["one-tap"] or {}
        if not gs["Quickscope Assist"] then return end
        pcall(function()
            if AimbotTarget and isAlive(AimbotTarget) then
                -- Scope in -> shoot -> scope out rapidly
                pcall(mouse2click) -- scope
                task.wait(0.05)
                pcall(mouse1click) -- shoot
                task.wait(0.05)
                pcall(mouse2click) -- unscope
            end
        end)
    end))
    
    -- No Scope Sway
    addConnection("ot_nosway", RunService.Heartbeat:Connect(function()
        local gs = Settings["one-tap"] or {}
        if not gs["No Scope Sway"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    local n = string.lower(v.Name)
                    if v:IsA("NumberValue") and (n:find("sway") or n:find("wobble") or n:find("breath")) then
                        v.Value = 0
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: BEE SWARM SIMULATOR
-- ============================================

local function initBeeSwarmSimulator()
    notify("Script Hub", "Bee Swarm Simulator module loaded!")
    
    -- Field positions (approximate, will search workspace)
    local function findField(fieldName)
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                if string.lower(obj.Name):find(string.lower(fieldName)) then
                    return obj
                end
            end
        end
        return nil
    end
    
    -- Auto Farm Pollen
    addConnection("bss_farm", RunService.Heartbeat:Connect(function()
        local gs = Settings["bee-swarm-simulator"] or {}
        if not gs["Auto Farm Pollen"] then return end
        pcall(function()
            local fieldName = gs["Farm Field"] or "Sunflower"
            local field = findField(fieldName)
            if field then
                local hrp = getHRP()
                if hrp then
                    local pos = field:IsA("Model") and field:GetBoundingBox().Position or field.Position
                    if (hrp.Position - pos).Magnitude > 20 then
                        teleportTo(pos + Vector3.new(math.random(-5,5), 3, math.random(-5,5)))
                    end
                    -- Simulate collecting by moving around
                    local hum = getHumanoid()
                    if hum then
                        hum:Move(Vector3.new(math.random(-1,1), 0, math.random(-1,1)))
                    end
                    -- Auto click/collect
                    pcall(mouse1click)
                end
            end
        end)
    end))
    
    -- Auto Convert Honey
    addConnection("bss_convert", RunService.Heartbeat:Connect(function()
        local gs = Settings["bee-swarm-simulator"] or {}
        if not gs["Auto Convert Honey"] then return end
        pcall(function()
            -- Find hive and interact
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("ProximityPrompt") and (n:find("convert") or n:find("hive") or n:find("honey")) then
                    local hrp = getHRP()
                    if hrp and obj.Parent:IsA("BasePart") then
                        local dist = (hrp.Position - obj.Parent.Position).Magnitude
                        if dist < obj.MaxActivationDistance + 10 then
                            fireproximityprompt(obj, 1)
                        end
                    end
                end
            end
        end)
    end))
    
    -- Token ESP
    addConnection("bss_tokenesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["bee-swarm-simulator"] or {}
        if not gs["Token ESP"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("BasePart") and (n:find("token") or n:find("ability")) then
                    if not obj:FindFirstChild("TokenHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "TokenHL"
                        hl.FillColor = Color3.fromRGB(255, 255, 100)
                        hl.FillTransparency = 0.3
                        hl.Parent = obj
                    end
                end
            end
        end)
    end))
    
    -- Auto Collect Tokens
    addConnection("bss_autotoken", RunService.Heartbeat:Connect(function()
        local gs = Settings["bee-swarm-simulator"] or {}
        if not gs["Auto Collect Tokens"] then return end
        pcall(function()
            local hrp = getHRP()
            if not hrp then return end
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("BasePart") and (n:find("token") or n:find("ability") or n:find("collect")) then
                    if (obj.Position - hrp.Position).Magnitude < 100 then
                        firetouchinterest(hrp, obj, 0)
                        task.wait()
                        firetouchinterest(hrp, obj, 1)
                    end
                end
            end
        end)
    end))
    
    -- Teleport buttons
    addConnection("bss_teleport", RunService.Heartbeat:Connect(function()
        local gs = Settings["bee-swarm-simulator"] or {}
        
        for btnName, searchTerm in pairs({
            ["Teleport to Hive"] = "hive",
            ["Teleport to Shop"] = "shop",
            ["Teleport to Bear"] = "bear"
        }) do
            if gs[btnName] then
                gs[btnName] = false
                pcall(function()
                    local found = findField(searchTerm)
                    if found then
                        local pos = found:IsA("Model") and found:GetBoundingBox().Position or found.Position
                        teleportTo(pos + Vector3.new(0, 5, 0))
                        notify("BSS", "Teleported to " .. searchTerm .. "!")
                    end
                end)
            end
        end
    end))
    
    -- Full Auto Macro
    addConnection("bss_macro", RunService.Heartbeat:Connect(function()
        local gs = Settings["bee-swarm-simulator"] or {}
        if not gs["Auto Macro"] then return end
        -- This combines auto farm + auto convert in a loop
        gs["Auto Farm Pollen"] = true
        gs["Auto Convert Honey"] = true
        gs["Auto Collect Tokens"] = true
    end))
end

-- ============================================
-- GAME-SPECIFIC: FLEE THE FACILITY
-- ============================================

local function initFleeTheFacility()
    notify("Script Hub", "Flee the Facility module loaded!")
    
    local BeastPlayer = nil
    
    -- Detect beast
    local function findBeast()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    -- Beast usually has different walkspeed or special tools
                    for _, item in pairs(player.Character:GetChildren()) do
                        if item:IsA("Tool") then
                            local n = string.lower(item.Name)
                            if n:find("hammer") or n:find("weapon") or n:find("beast") then
                                return player
                            end
                        end
                    end
                    -- Check walkspeed (beast is usually faster)
                    if hum.WalkSpeed > 20 then
                        return player
                    end
                end
            end
        end
        return nil
    end
    
    addConnection("ftf_beast", RunService.Heartbeat:Connect(function()
        BeastPlayer = findBeast()
        local gs = Settings["flee-the-facility"] or {}
        
        -- Beast ESP
        if gs["Beast ESP"] and BeastPlayer and BeastPlayer.Character then
            if not BeastPlayer.Character:FindFirstChild("BeastHL") then
                local hl = Instance.new("Highlight")
                hl.Name = "BeastHL"
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.3
                hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                hl.Parent = BeastPlayer.Character
            end
            
            local head = BeastPlayer.Character:FindFirstChild("Head")
            if head and not head:FindFirstChild("BeastTag") then
                local bb = Instance.new("BillboardGui")
                bb.Name = "BeastTag"
                bb.Adornee = head
                bb.Size = UDim2.new(0, 120, 0, 25)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = head
                
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 0, 0)
                label.TextStrokeTransparency = 0
                label.Font = Enum.Font.GothamBold
                label.TextSize = 16
                label.Text = "🔨 BEAST"
                label.Parent = bb
            end
        end
        
        -- Beast Proximity Alert
        if gs["Beast Proximity Alert"] and BeastPlayer and BeastPlayer.Character then
            local myHRP = getHRP()
            local bHRP = BeastPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and bHRP then
                local dist = (myHRP.Position - bHRP.Position).Magnitude
                local alertDist = gs["Alert Distance"] or 40
                if dist < alertDist then
                    notify("⚠️ BEAST NEARBY", math.floor(dist) .. " studs away! RUN!", 0.5)
                end
            end
        end
    end))
    
    -- Computer ESP
    addConnection("ftf_compesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["flee-the-facility"] or {}
        if not gs["Computer ESP"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if obj:IsA("Model") and (n:find("computer") or n:find("terminal") or n:find("hack")) then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part and not part:FindFirstChild("CompHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "CompHL"
                        hl.FillColor = Color3.fromRGB(0, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(0, 200, 255)
                        hl.Adornee = obj
                        hl.Parent = part
                        
                        local bb = Instance.new("BillboardGui")
                        bb.Name = "CompBB"
                        bb.Adornee = part
                        bb.Size = UDim2.new(0, 100, 0, 25)
                        bb.StudsOffset = Vector3.new(0, 4, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = part
                        
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(0, 255, 255)
                        label.TextStrokeTransparency = 0
                        label.Font = Enum.Font.GothamBold
                        label.TextSize = 12
                        label.Text = "💻 Computer"
                        label.Parent = bb
                    end
                end
            end
        end)
    end))
    
    -- Exit ESP
    addConnection("ftf_exitesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["flee-the-facility"] or {}
        if not gs["Exit ESP"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                local n = string.lower(obj.Name)
                if (obj:IsA("BasePart") or obj:IsA("Model")) and (n:find("exit") or n:find("escape") or n:find("gate")) then
                    local part = obj:IsA("Model") and obj.PrimaryPart or obj
                    if part and not part:FindFirstChild("ExitHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ExitHL"
                        hl.FillColor = Color3.fromRGB(0, 255, 0)
                        hl.FillTransparency = 0.3
                        hl.OutlineColor = Color3.fromRGB(0, 200, 0)
                        hl.Parent = part
                    end
                end
            end
        end)
    end))
    
    -- Auto Hack
    addConnection("ftf_autohack", RunService.Heartbeat:Connect(function()
        local gs = Settings["flee-the-facility"] or {}
        if not (gs["Auto Hack"] or gs["Instant Hack"]) then return end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local n = string.lower(v.Name)
                    if n:find("hack") or n:find("computer") or n:find("terminal") then
                        local hrp = getHRP()
                        if hrp and v.Parent:IsA("BasePart") then
                            if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 5 then
                                fireproximityprompt(v, gs["Instant Hack"] and 0 or 1)
                            end
                        end
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: GROW A GARDEN
-- ============================================

local function initGrowAGarden()
    notify("Script Hub", "Grow a Garden module loaded!")
    
    -- Auto Plant
    addConnection("gag_plant", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if not gs["Auto Plant"] then return end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and string.lower(v.Name):find("plant") then
                    local hrp = getHRP()
                    if hrp and v.Parent:IsA("BasePart") then
                        if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 5 then
                            fireproximityprompt(v, 1)
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Water
    addConnection("gag_water", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if not gs["Auto Water"] then return end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and string.lower(v.Name):find("water") then
                    local hrp = getHRP()
                    if hrp and v.Parent:IsA("BasePart") then
                        if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 5 then
                            fireproximityprompt(v, 1)
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Harvest
    addConnection("gag_harvest", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if not gs["Auto Harvest"] then return end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local n = string.lower(v.Name)
                    if n:find("harvest") or n:find("collect") or n:find("pick") then
                        local hrp = getHRP()
                        if hrp and v.Parent:IsA("BasePart") then
                            if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 5 then
                                fireproximityprompt(v, 1)
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Sell
    addConnection("gag_sell", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if not gs["Auto Sell"] then return end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and string.lower(v.Name):find("sell") then
                    local hrp = getHRP()
                    if hrp and v.Parent:IsA("BasePart") then
                        if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 5 then
                            fireproximityprompt(v, 1)
                        end
                    end
                end
            end
        end)
    end))
    
    -- Plant ESP with growth stage
    addConnection("gag_plantesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if not gs["Plant ESP"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and string.lower(obj.Name):find("plant") then
                    local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if part and not part:FindFirstChild("PlantHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "PlantHL"
                        hl.FillColor = Color3.fromRGB(0, 200, 50)
                        hl.FillTransparency = 0.5
                        hl.Parent = part
                    end
                end
            end
        end)
    end))
    
    -- Instant Grow
    addConnection("gag_instantgrow", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if not gs["Instant Grow"] then return end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                local n = string.lower(v.Name)
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (n:find("growth") or n:find("stage") or n:find("timer") or n:find("grow")) then
                    v.Value = 999
                end
            end
        end)
    end))
    
    -- Full Farm Loop
    addConnection("gag_farmloop", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if not gs["Full Farm Loop"] then return end
        gs["Auto Plant"] = true
        gs["Auto Water"] = true
        gs["Auto Harvest"] = true
        gs["Auto Sell"] = true
    end))
    
    -- Teleports
    addConnection("gag_tp", RunService.Heartbeat:Connect(function()
        local gs = Settings["grow-a-garden"] or {}
        if gs["Teleport to Shop"] then
            gs["Teleport to Shop"] = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.lower(obj.Name):find("shop") then
                    teleportTo(obj.Position + Vector3.new(0, 3, 0)); break
                end
            end
        end
        if gs["Teleport to Garden"] then
            gs["Teleport to Garden"] = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.lower(obj.Name):find("garden") then
                    teleportTo(obj.Position + Vector3.new(0, 3, 0)); break
                end
            end
        end
    end))
end

-- ============================================
-- GAME-SPECIFIC: BLOXSTRIKE
-- ============================================

local function initBloxStrike()
    notify("Script Hub", "BloxStrike module loaded!")
    -- Uses shared FPS systems (aimbot, ESP, movement)
    
    -- Bunny Hop
    addConnection("bs_bhop", RunService.Heartbeat:Connect(function()
        local gs = Settings["bloxstrike"] or {}
        if not gs["Bunny Hop"] then return end
        local hum = getHumanoid()
        if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
    
    -- Auto Defuse/Plant
    addConnection("bs_bombinteract", RunService.Heartbeat:Connect(function()
        local gs = Settings["bloxstrike"] or {}
        if not gs["Auto Defuse/Plant"] then return end
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local n = string.lower(v.Name)
                    if n:find("plant") or n:find("defuse") or n:find("bomb") then
                        local hrp = getHRP()
                        if hrp and v.Parent:IsA("BasePart") then
                            if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 5 then
                                fireproximityprompt(v, 1)
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- Bomb ESP
    addConnection("bs_bombesp", RunService.Heartbeat:Connect(function()
        local gs = Settings["bloxstrike"] or {}
        if not gs["Bomb ESP"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.lower(obj.Name):find("bomb") then
                    if not obj:FindFirstChild("BombHL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "BombHL"
                        hl.FillColor = Color3.fromRGB(255, 165, 0)
                        hl.FillTransparency = 0.3
                        hl.Parent = obj
                    end
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: BREAK YOUR BONES
-- ============================================

local function initBreakYourBones()
    notify("Script Hub", "Break Your Bones module loaded!")
    
    -- Super Launch
    addConnection("byb_launch", RunService.Heartbeat:Connect(function()
        local gs = Settings["break-your-bones"] or {}
        if not gs["Super Launch"] then return end
        local mult = gs["Launch Force Multiplier"] or 5
        pcall(function()
            local hrp = getHRP()
            if hrp and hrp.AssemblyLinearVelocity.Magnitude > 10 then
                hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity * (1 + (mult - 1) * 0.01)
            end
        end)
    end))
    
    -- Anti-Gravity
    addConnection("byb_gravity", RunService.Heartbeat:Connect(function()
        local gs = Settings["break-your-bones"] or {}
        if not gs["Anti-Gravity"] then 
            workspace.Gravity = 196.2
            return 
        end
        local mult = (gs["Gravity Multiplier"] or 100) / 100
        workspace.Gravity = 196.2 * mult
    end))
    
    -- Infinite Bounces
    addConnection("byb_bounce", RunService.Heartbeat:Connect(function()
        local gs = Settings["break-your-bones"] or {}
        if not gs["Infinite Bounces"] then return end
        pcall(function()
            local hrp = getHRP()
            if hrp then
                -- Maintain velocity on ground contact
                local vel = hrp.AssemblyLinearVelocity
                if vel.Magnitude > 5 and vel.Y < -1 then
                    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, math.abs(vel.Y) * 0.9, vel.Z)
                end
            end
        end)
    end))
    
    -- Auto Launch Optimal
    addConnection("byb_autolaunch", RunService.Heartbeat:Connect(function()
        local gs = Settings["break-your-bones"] or {}
        if not gs["Auto Launch Optimal"] then return end
        pcall(function()
            -- Find launch pad/area
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and string.lower(v.Name):find("launch") then
                    local hrp = getHRP()
                    if hrp and v.Parent:IsA("BasePart") then
                        if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 5 then
                            fireproximityprompt(v, 1)
                        end
                    end
                end
            end
        end)
    end))
    
    -- Score Multiplier
    addConnection("byb_score", RunService.Heartbeat:Connect(function()
        local gs = Settings["break-your-bones"] or {}
        local mult = gs["Score Multiplier"]
        if not mult or mult <= 1 then return end
        pcall(function()
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            if ls then
                for _, v in pairs(ls:GetChildren()) do
                    local n = string.lower(v.Name)
                    if n:find("bone") or n:find("break") or n:find("score") or n:find("point") then
                        -- Apply multiplier
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            -- Only apply on change
                            if not v:GetAttribute("LastVal") then
                                v:SetAttribute("LastVal", v.Value)
                            end
                            local last = v:GetAttribute("LastVal")
                            if v.Value > last then
                                local diff = v.Value - last
                                v.Value = last + diff * mult
                            end
                            v:SetAttribute("LastVal", v.Value)
                        end
                    end
                end
            end
        end)
    end))
    
    -- Teleports
    addConnection("byb_tp", RunService.Heartbeat:Connect(function()
        local gs = Settings["break-your-bones"] or {}
        if gs["Teleport to Best Launch Spot"] or gs["Teleport to Top of Map"] then
            gs["Teleport to Best Launch Spot"] = false
            gs["Teleport to Top of Map"] = false
            -- Find highest point
            local highest, highY = nil, -math.huge
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Position.Y > highY then
                    highY = obj.Position.Y
                    highest = obj
                end
            end
            if highest then
                teleportTo(highest.Position + Vector3.new(0, 10, 0))
                notify("BYB", "Teleported to highest point!")
            end
        end
        if gs["Max Bone Breaks"] then
            gs["Max Bone Breaks"] = false
            pcall(function()
                local ls = LocalPlayer:FindFirstChild("leaderstats")
                if ls then
                    for _, v in pairs(ls:GetChildren()) do
                        if (v:IsA("NumberValue") or v:IsA("IntValue")) then
                            v.Value = 999999
                        end
                    end
                end
            end)
            notify("BYB", "Bones set to max!")
        end
    end))
end

-- ============================================
-- GAME-SPECIFIC: SLIME RNG
-- ============================================

local function initSlimeRNG()
    notify("Script Hub", "Slime RNG module loaded!")
    
    -- Auto Roll
    addConnection("srng_roll", RunService.Heartbeat:Connect(function()
        local gs = Settings["slime-rng"] or {}
        if not gs["Auto Roll"] then return end
        pcall(function()
            -- Find roll mechanism
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") then
                    local n = string.lower(v.Name)
                    if n:find("roll") or n:find("spin") or n:find("hatch") or n:find("open") then
                        local hrp = getHRP()
                        if hrp and v.Parent:IsA("BasePart") then
                            if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 10 then
                                fireproximityprompt(v, 1)
                            end
                        end
                    end
                end
            end
            -- Also try remote events
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local n = string.lower(remote.Name)
                    if n:find("roll") or n:find("spin") or n:find("hatch") then
                        remote:FireServer()
                    end
                end
            end
        end)
    end))
    
    -- Instant Roll (remove animation delay)
    addConnection("srng_instant", RunService.Heartbeat:Connect(function()
        local gs = Settings["slime-rng"] or {}
        if not gs["Instant Roll"] then return end
        pcall(function()
            -- Skip animations
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, v in pairs(pgui:GetDescendants()) do
                    if v:IsA("Frame") then
                        local n = string.lower(v.Name)
                        if n:find("roll") or n:find("animation") or n:find("reveal") then
                            v.Visible = false
                        end
                    end
                end
            end
        end)
    end))
    
    -- Auto Sell Duplicates
    addConnection("srng_sell", RunService.Heartbeat:Connect(function()
        local gs = Settings["slime-rng"] or {}
        if not gs["Auto Sell Duplicates"] then return end
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and string.lower(remote.Name):find("sell") then
                    remote:FireServer("duplicates")
                end
            end
        end)
    end))
    
    -- Auto Rebirth
    addConnection("srng_rebirth", RunService.Heartbeat:Connect(function()
        local gs = Settings["slime-rng"] or {}
        if not gs["Auto Rebirth"] then return end
        pcall(function()
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and string.lower(remote.Name):find("rebirth") then
                    remote:FireServer()
                end
            end
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and string.lower(v.Name):find("rebirth") then
                    local hrp = getHRP()
                    if hrp and v.Parent:IsA("BasePart") then
                        if (hrp.Position - v.Parent.Position).Magnitude < v.MaxActivationDistance + 10 then
                            fireproximityprompt(v, 1)
                        end
                    end
                end
            end
        end)
    end))
    
    -- Teleports
    addConnection("srng_tp", RunService.Heartbeat:Connect(function()
        local gs = Settings["slime-rng"] or {}
        for btnName, search in pairs({
            ["Teleport to Roll Area"] = "roll",
            ["Teleport to Shop"] = "shop",
            ["Teleport to Trade Area"] = "trade"
        }) do
            if gs[btnName] then
                gs[btnName] = false
                pcall(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and string.lower(obj.Name):find(search) then
                            teleportTo(obj.Position + Vector3.new(0, 3, 0))
                            notify("Slime RNG", "Teleported!")
                            break
                        end
                    end
                end)
            end
        end
    end))
    
    -- Luck Boost
    addConnection("srng_luck", RunService.Heartbeat:Connect(function()
        local gs = Settings["slime-rng"] or {}
        local luck = gs["Luck Boost"]
        if not luck or luck <= 1 then return end
        pcall(function()
            for _, v in pairs(LocalPlayer:GetDescendants()) do
                local n = string.lower(v.Name)
                if (v:IsA("NumberValue") or v:IsA("IntValue")) and (n:find("luck") or n:find("multi")) then
                    v.Value = luck
                end
            end
        end)
    end))
end

-- ============================================
-- GAME-SPECIFIC: REDLINERS
-- ============================================

local function initRedliners()
    notify("Script Hub", "Redliners module loaded!")
    -- Uses shared FPS combat systems (aimbot, ESP, etc.)
    
    -- Hit Registration Boost
    addConnection("rl_hitreg", RunService.Heartbeat:Connect(function()
        local gs = Settings["redliners"] or {}
        if not gs["Hit Registration Boost"] then return end
        pcall(function()
            -- Expand hitboxes slightly for better hit reg
            for _, player in pairs(Players:GetPlayers()) do
                if isEnemy(player) and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.Size = part.Size:Max(Vector3.new(3, 3, 3))
                        end
                    end
                end
            end
        end)
    end))
    
    -- Instant Reload
    addConnection("rl_instreload", RunService.Heartbeat:Connect(function()
        local gs = Settings["redliners"] or {}
        if not gs["Instant Reload"] then return end
        pcall(function()
            local char = getCharacter()
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in pairs(tool:GetDescendants()) do
                            local n = string.lower(v.Name)
                            if (v:IsA("NumberValue")) and (n:find("reload") and n:find("time") or n:find("reloadspeed")) then
                                v.Value = 0.01
                            end
                        end
                    end
                end
            end
        end)
    end))
    
    -- No Flash
    addConnection("rl_noflash", RunService.Heartbeat:Connect(function()
        local gs = Settings["redliners"] or {}
        if not gs["No Flash"] then return end
        pcall(function()
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                for _, v in pairs(pgui:GetDescendants()) do
                    if v:IsA("Frame") then
                        local n = string.lower(v.Name)
                        if n:find("flash") or n:find("blind") or n:find("white") then
                            v.Visible = false
                            v.BackgroundTransparency = 1
                        end
                    end
                end
            end
        end)
    end))
    
    -- No Smoke
    addConnection("rl_nosmoke", RunService.Heartbeat:Connect(function()
        local gs = Settings["redliners"] or {}
        if not gs["No Smoke"] then return end
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Smoke") or obj:IsA("ParticleEmitter") then
                    local n = string.lower(obj.Name)
                    if n:find("smoke") or n:find("fog") then
                        obj.Enabled = false
                        obj:Destroy()
                    end
                end
            end
        end)
    end))
    
    -- Bunny Hop
    addConnection("rl_bhop", RunService.Heartbeat:Connect(function()
        local gs = Settings["redliners"] or {}
        if not gs["Bunny Hop"] then return end
        local hum = getHumanoid()
        if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end))
    
    -- Kill All
    addConnection("rl_killall", RunService.Heartbeat:Connect(function()
        local gs = Settings["redliners"] or {}
        if not gs["Kill All"] then return end
        gs["Kill All"] = false
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if isEnemy(player) and player.Character then
                    local hum = player.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
        end)
        notify("Redliners", "Kill All triggered!")
    end))
    
    -- Teleport to Spawn
    addConnection("rl_spawn", RunService.Heartbeat:Connect(function()
        local gs = Settings["redliners"] or {}
        if not gs["Teleport to Spawn"] then return end
        gs["Teleport to Spawn"] = false
        pcall(function()
            for _, spawn in pairs(workspace:GetDescendants()) do
                if spawn:IsA("SpawnLocation") then
                    teleportTo(spawn.Position + Vector3.new(0, 5, 0))
                    notify("Redliners", "Teleported to spawn!")
                    break
                end
            end
        end)
    end))
end


--[[ ============================================
     GUI SYSTEM - MAIN HUB INTERFACE
     ============================================ ]]

local function createMainGUI()
    -- Cleanup existing
    local existing = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ScriptHubGUI")
    if existing then existing:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ScriptHubGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(60, 60, 80)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageTransparency = 0.5
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.ZIndex = -1
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Fix bottom corners of title bar
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 10)
    TitleFix.Position = UDim2.new(0, 0, 1, -10)
    TitleFix.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "⚡ Universal Script Hub"
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 6)
    CloseBtnCorner.Parent = CloseBtn
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "MinBtn"
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Position = UDim2.new(1, -60, 0, 5)
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TitleBar
    
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 6)
    MinBtnCorner.Parent = MinBtn
    
    -- Dragging
    local dragging = false
    local dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, 0, 1, -35)
    ContentArea.Position = UDim2.new(0, 0, 0, 35)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    -- Left Panel (Game List)
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Name = "LeftPanel"
    LeftPanel.Size = UDim2.new(0, 170, 1, -10)
    LeftPanel.Position = UDim2.new(0, 5, 0, 5)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = ContentArea
    
    local LeftCorner = Instance.new("UICorner")
    LeftCorner.CornerRadius = UDim.new(0, 6)
    LeftCorner.Parent = LeftPanel
    
    -- Search Box
    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -10, 0, 28)
    SearchBox.Position = UDim2.new(0, 5, 0, 5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    SearchBox.PlaceholderText = "🔍 Search games..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 11
    SearchBox.BorderSizePixel = 0
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = LeftPanel
    
    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 5)
    SearchCorner.Parent = SearchBox
    
    -- Game List ScrollFrame
    local GameListScroll = Instance.new("ScrollingFrame")
    GameListScroll.Name = "GameListScroll"
    GameListScroll.Size = UDim2.new(1, -10, 1, -43)
    GameListScroll.Position = UDim2.new(0, 5, 0, 38)
    GameListScroll.BackgroundTransparency = 1
    GameListScroll.ScrollBarThickness = 4
    GameListScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
    GameListScroll.BorderSizePixel = 0
    GameListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    GameListScroll.Parent = LeftPanel
    
    local GameListLayout = Instance.new("UIListLayout")
    GameListLayout.Padding = UDim.new(0, 3)
    GameListLayout.Parent = GameListScroll
    
    -- Right Panel (Feature Display)
    local RightPanel = Instance.new("Frame")
    RightPanel.Name = "RightPanel"
    RightPanel.Size = UDim2.new(1, -180, 1, -10)
    RightPanel.Position = UDim2.new(0, 180, 0, 5)
    RightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = ContentArea
    
    local RightCorner = Instance.new("UICorner")
    RightCorner.CornerRadius = UDim.new(0, 6)
    RightCorner.Parent = RightPanel
    
    -- Game Title in Right Panel
    local GameTitle = Instance.new("TextLabel")
    GameTitle.Name = "GameTitle"
    GameTitle.Size = UDim2.new(1, -10, 0, 30)
    GameTitle.Position = UDim2.new(0, 10, 0, 5)
    GameTitle.BackgroundTransparency = 1
    GameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    GameTitle.Font = Enum.Font.GothamBold
    GameTitle.TextSize = 16
    GameTitle.TextXAlignment = Enum.TextXAlignment.Left
    GameTitle.Text = "Select a game"
    GameTitle.Parent = RightPanel
    
    -- Category Tabs
    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -10, 0, 28)
    TabBar.Position = UDim2.new(0, 5, 0, 35)
    TabBar.BackgroundTransparency = 1
    TabBar.ScrollBarThickness = 0
    TabBar.BorderSizePixel = 0
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.ScrollingDirection = Enum.ScrollingDirection.X
    TabBar.Parent = RightPanel
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabBar
    
    -- Feature ScrollFrame
    local FeatureScroll = Instance.new("ScrollingFrame")
    FeatureScroll.Name = "FeatureScroll"
    FeatureScroll.Size = UDim2.new(1, -10, 1, -73)
    FeatureScroll.Position = UDim2.new(0, 5, 0, 68)
    FeatureScroll.BackgroundTransparency = 1
    FeatureScroll.ScrollBarThickness = 4
    FeatureScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
    FeatureScroll.BorderSizePixel = 0
    FeatureScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    FeatureScroll.Parent = RightPanel
    
    local FeatureLayout = Instance.new("UIListLayout")
    FeatureLayout.Padding = UDim.new(0, 4)
    FeatureLayout.Parent = FeatureScroll
    
    -- Build Game List
    local gameButtons = {}
    local selectedGame = nil
    local selectedCategory = nil
    
    local function createToggle(parent, feature, gameId)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -6, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 5)
        fCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -55, 0, 16)
        label.Position = UDim2.new(0, 8, 0, 2)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220, 220, 230)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = feature.name
        label.Parent = frame
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -55, 0, 12)
        desc.Position = UDim2.new(0, 8, 0, 18)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(120, 120, 140)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 9
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Text = feature.description
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 38, 0, 20)
        toggle.Position = UDim2.new(1, -44, 0.5, -10)
        toggle.BorderSizePixel = 0
        toggle.Text = ""
        toggle.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggle
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = UDim2.new(0, 2, 0.5, -8)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.Parent = toggle
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = circle
        
        local isOn = Settings[gameId] and Settings[gameId][feature.name] or false
        
        local function updateVisual()
            if isOn then
                toggle.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                TweenService:Create(circle, TweenInfo.new(0.15), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            else
                toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                TweenService:Create(circle, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            end
        end
        
        updateVisual()
        
        toggle.MouseButton1Click:Connect(function()
            isOn = not isOn
            if not Settings[gameId] then Settings[gameId] = {} end
            Settings[gameId][feature.name] = isOn
            updateVisual()
        end)
        
        return frame
    end
    
    local function createSlider(parent, feature, gameId)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -6, 0, 44)
        frame.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 5)
        fCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 0, 14)
        label.Position = UDim2.new(0, 8, 0, 3)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220, 220, 230)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = feature.name
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 0, 14)
        valueLabel.Position = UDim2.new(1, -55, 0, 3)
        valueLabel.BackgroundTransparency = 1
        valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 11
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -16, 0, 8)
        sliderBg.Position = UDim2.new(0, 8, 0, 22)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = frame
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(1, 0)
        sliderBgCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(1, 0)
        sliderFillCorner.Parent = sliderFill
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -16, 0, 10)
        desc.Position = UDim2.new(0, 8, 0, 32)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(100, 100, 120)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 8
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Text = feature.description
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Parent = frame
        
        local minVal = feature.min or 0
        local maxVal = feature.max or 100
        local currentVal = (Settings[gameId] and Settings[gameId][feature.name]) or feature.defaultValue or minVal
        
        local function updateSlider(val)
            currentVal = math.clamp(val, minVal, maxVal)
            if not Settings[gameId] then Settings[gameId] = {} end
            Settings[gameId][feature.name] = currentVal
            local pct = (currentVal - minVal) / (maxVal - minVal)
            sliderFill.Size = UDim2.new(math.max(pct, 0.01), 0, 1, 0)
            valueLabel.Text = tostring(math.floor(currentVal))
        end
        
        updateSlider(currentVal)
        
        local sliding = false
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
            end
        end)
        sliderBg.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
                relX = math.clamp(relX, 0, 1)
                updateSlider(minVal + (maxVal - minVal) * relX)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)
        
        return frame
    end
    
    local function createButton(parent, feature, gameId)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -6, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11
        btn.Text = "▶  " .. feature.name
        btn.BorderSizePixel = 0
        btn.Parent = parent
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if not Settings[gameId] then Settings[gameId] = {} end
            Settings[gameId][feature.name] = true
            -- Flash feedback
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
            task.delay(0.3, function()
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
            end)
        end)
        
        -- Hover effects
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 100)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 80)}):Play()
        end)
        
        return btn
    end
    
    local function createDropdown(parent, feature, gameId)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -6, 0, 32)
        frame.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = false
        frame.Parent = parent
        
        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 5)
        fCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, -5, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(220, 220, 230)
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = feature.name
        label.Parent = frame
        
        local currentVal = (Settings[gameId] and Settings[gameId][feature.name]) or feature.defaultValue or (feature.options and feature.options[1]) or ""
        
        local dropBtn = Instance.new("TextButton")
        dropBtn.Size = UDim2.new(0.45, 0, 0, 24)
        dropBtn.Position = UDim2.new(0.52, 0, 0.5, -12)
        dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        dropBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
        dropBtn.Font = Enum.Font.Gotham
        dropBtn.TextSize = 10
        dropBtn.Text = tostring(currentVal) .. " ▾"
        dropBtn.BorderSizePixel = 0
        dropBtn.Parent = frame
        
        local dropCorner = Instance.new("UICorner")
        dropCorner.CornerRadius = UDim.new(0, 4)
        dropCorner.Parent = dropBtn
        
        local optionIdx = 1
        for i, opt in ipairs(feature.options or {}) do
            if opt == currentVal then optionIdx = i end
        end
        
        dropBtn.MouseButton1Click:Connect(function()
            if feature.options and #feature.options > 0 then
                optionIdx = optionIdx % #feature.options + 1
                currentVal = feature.options[optionIdx]
                if not Settings[gameId] then Settings[gameId] = {} end
                Settings[gameId][feature.name] = currentVal
                dropBtn.Text = currentVal .. " ▾"
            end
        end)
        
        return frame
    end
    
    local function loadFeatures(gameId, category)
        -- Clear current features
        for _, child in pairs(FeatureScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        local gameData = nil
        for _, g in ipairs(GameList) do
            if g.id == gameId then gameData = g; break end
        end
        if not gameData then return end
        
        for _, feature in ipairs(gameData.features) do
            if feature.category == category then
                if feature.type == "toggle" then
                    createToggle(FeatureScroll, feature, gameId)
                elseif feature.type == "slider" then
                    createSlider(FeatureScroll, feature, gameId)
                elseif feature.type == "button" then
                    createButton(FeatureScroll, feature, gameId)
                elseif feature.type == "dropdown" then
                    createDropdown(FeatureScroll, feature, gameId)
                end
            end
        end
        
        -- Update canvas size
        FeatureScroll.CanvasSize = UDim2.new(0, 0, 0, FeatureLayout.AbsoluteContentSize.Y + 10)
    end
    
    local function loadGame(gameId)
        selectedGame = gameId
        
        local gameData = nil
        for _, g in ipairs(GameList) do
            if g.id == gameId then gameData = g; break end
        end
        if not gameData then return end
        
        GameTitle.Text = gameData.icon .. " " .. gameData.name
        
        -- Clear tabs
        for _, child in pairs(TabBar:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        -- Get categories
        local categories = {}
        local catSet = {}
        for _, f in ipairs(gameData.features) do
            if not catSet[f.category] then
                catSet[f.category] = true
                table.insert(categories, f.category)
            end
        end
        
        -- Create category tabs
        for i, cat in ipairs(categories) do
            local tab = Instance.new("TextButton")
            tab.Size = UDim2.new(0, math.max(#cat * 7 + 16, 60), 1, -4)
            tab.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 60)
            tab.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab.Font = Enum.Font.GothamMedium
            tab.TextSize = 10
            tab.Text = cat
            tab.BorderSizePixel = 0
            tab.Parent = TabBar
            
            local tabCorner = Instance.new("UICorner")
            tabCorner.CornerRadius = UDim.new(0, 4)
            tabCorner.Parent = tab
            
            tab.MouseButton1Click:Connect(function()
                selectedCategory = cat
                for _, t in pairs(TabBar:GetChildren()) do
                    if t:IsA("TextButton") then
                        t.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                    end
                end
                tab.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
                loadFeatures(gameId, cat)
            end)
        end
        
        -- Update tab bar canvas
        TabBar.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 10, 0, 0)
        
        -- Load first category
        if #categories > 0 then
            selectedCategory = categories[1]
            loadFeatures(gameId, categories[1])
        end
        
        -- Highlight selected game button
        for id, btn in pairs(gameButtons) do
            if id == gameId then
                btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
            else
                btn.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
            end
        end
    end
    
    -- Populate game list
    local function populateGameList(filter)
        for _, child in pairs(GameListScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        gameButtons = {}
        
        for _, gameData in ipairs(GameList) do
            if not filter or filter == "" or string.find(string.lower(gameData.name), string.lower(filter)) then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -4, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
                btn.TextColor3 = Color3.fromRGB(200, 200, 210)
                btn.Font = Enum.Font.GothamMedium
                btn.TextSize = 11
                btn.Text = "  " .. gameData.icon .. " " .. gameData.name
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.BorderSizePixel = 0
                btn.Parent = GameListScroll
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 5)
                btnCorner.Parent = btn
                
                gameButtons[gameData.id] = btn
                
                btn.MouseButton1Click:Connect(function()
                    loadGame(gameData.id)
                end)
                
                btn.MouseEnter:Connect(function()
                    if selectedGame ~= gameData.id then
                        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(48, 48, 65)}):Play()
                    end
                end)
                btn.MouseLeave:Connect(function()
                    if selectedGame ~= gameData.id then
                        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(38, 38, 52)}):Play()
                    end
                end)
            end
        end
        
        GameListScroll.CanvasSize = UDim2.new(0, 0, 0, GameListLayout.AbsoluteContentSize.Y + 5)
    end
    
    populateGameList()
    
    -- Search filter
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populateGameList(SearchBox.Text)
    end)
    
    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        cleanupAll()
    end)
    
    -- Minimize
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        ContentArea.Visible = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 550, 0, 35)
        else
            MainFrame.Size = UDim2.new(0, 550, 0, 400)
        end
    end)
    
    -- Auto-load detected game
    if CurrentGame then
        loadGame(CurrentGame)
    end
    
    return ScreenGui
end


--[[ ============================================
     INITIALIZATION
     ============================================ ]]

local GameInitializers = {
    ["arsenal"] = initArsenal,
    ["rivals"] = initRivals,
    ["hypershot"] = initHypershot,
    ["jailbreak"] = initJailbreak,
    ["combat-arena"] = initCombatArena,
    ["steal-a-brainrot"] = initStealABrainrot,
    ["murder-mystery-2"] = initMurderMystery2,
    ["blade-ball"] = initBladeBall,
    ["tower-of-hell"] = initTowerOfHell,
    ["da-hood"] = initDaHood,
    ["natural-disaster-survival"] = initNaturalDisasterSurvival,
    ["one-tap"] = initOneTap,
    ["bee-swarm-simulator"] = initBeeSwarmSimulator,
    ["flee-the-facility"] = initFleeTheFacility,
    ["grow-a-garden"] = initGrowAGarden,
    ["bloxstrike"] = initBloxstrike,
    ["break-your-bones"] = initBreakYourBones,
    ["slime-rng"] = initSlimeRNG,
    ["redliners"] = initRedliners
}

local function initialize()
    -- Detect current game
    CurrentGame = detectGame()
    
    if CurrentGame then
        notify("Script Hub", "Detected game: " .. CurrentGame, 5)
        print("[Script Hub] Detected game: " .. CurrentGame)
    else
        notify("Script Hub", "No game detected - manual selection mode", 5)
        print("[Script Hub] No specific game detected, loading all modules")
    end
    
    -- Initialize core systems
    initESP()
    initAimbot()
    initAutoShoot()
    initNoRecoil()
    initMovementHacks()
    initFlyToggle()
    initGodMode()
    initAntiAFK()
    
    -- Initialize all game-specific modules
    for gameId, initFunc in pairs(GameInitializers) do
        pcall(function()
            initFunc()
        end)
    end
    
    -- Create GUI
    local gui = createMainGUI()
    
    -- Toggle GUI with RightShift
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            if gui and gui.Parent then
                gui.Enabled = not gui.Enabled
            else
                gui = createMainGUI()
            end
        end
        if input.KeyCode == Enum.KeyCode.F5 then
            cleanupAll()
            notify("Script Hub", "Emergency cleanup complete!")
        end
    end)
    
    print("[Script Hub] ✅ Fully loaded! Press RightShift to toggle GUI.")
    notify("✅ Script Hub", "Loaded! RightShift = Toggle GUI", 5)
end

-- Start
task.spawn(initialize)
