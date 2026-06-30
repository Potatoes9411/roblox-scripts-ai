-- [[ Full Studio Test Hub - Multi-Game Functional Edition ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ UI Setup ]] --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StudioTestHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Hub = {}
local Windows = {}
local ActiveConns = {}

-- Connection Manager to prevent memory leaks when toggling features
local function Bind(name, event, callback)
	if ActiveConns[name] then ActiveConns[name]:Disconnect() end
	ActiveConns[name] = event:Connect(callback)
end

local function Unbind(name)
	if ActiveConns[name] then
		ActiveConns[name]:Disconnect()
		ActiveConns[name] = nil
	end
end

function Hub.CreateWindow(title)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0, 500, 0, 450)
	Frame.Position = UDim2.new(0.5, -250, 0.5, -225)
	Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Frame.BorderSizePixel = 0
	Frame.Active = true
	Frame.Draggable = true
	Frame.Visible = false
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = Frame
	
	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 40)
	TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	TitleBar.Parent = Frame
	
	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 8)
	TitleCorner.Parent = TitleBar
	
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -100, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = title
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 14
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TitleBar
	
	local BackBtn = Instance.new("TextButton")
	BackBtn.Size = UDim2.new(0, 60, 0, 40)
	BackBtn.Position = UDim2.new(1, -120, 0, 0)
	BackBtn.BackgroundTransparency = 1
	BackBtn.Text = "BACK"
	BackBtn.TextColor3 = Color3.fromRGB(150, 150, 255)
	BackBtn.Font = Enum.Font.GothamBold
	BackBtn.TextSize = 12
	BackBtn.Parent = TitleBar
	
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -40, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 14
	CloseBtn.Parent = TitleBar
	
	local ContentScroll = Instance.new("ScrollingFrame")
	ContentScroll.Size = UDim2.new(1, -20, 1, -50)
	ContentScroll.Position = UDim2.new(0, 10, 0, 45)
	ContentScroll.BackgroundTransparency = 1
	ContentScroll.ScrollBarThickness = 4
	ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ContentScroll.Parent = Frame
	
	local Layout = Instance.new("UIListLayout")
	Layout.Parent = ContentScroll
	Layout.Padding = UDim.new(0, 8)
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	return Frame, ContentScroll, CloseBtn, BackBtn
end

function Hub.AddToggle(parent, text, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -10, 0, 35)
	Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	Btn.Text = ""
	Btn.Parent = parent
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Btn
	
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -50, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Btn
	
	local State = false
	Btn.MouseButton1Click:Connect(function()
		State = not State
		Btn.BackgroundColor3 = State and Color3.fromRGB(45, 100, 45) or Color3.fromRGB(40, 40, 45)
		callback(State)
	end)
end

function Hub.AddButton(parent, text, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -10, 0, 35)
	Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	Btn.Text = text
	Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
	Btn.Font = Enum.Font.Gotham
	Btn.TextSize = 13
	Btn.Parent = parent
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Btn
	
	Btn.MouseButton1Click:Connect(function()
		Btn.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
		task.wait(0.1)
		Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		callback()
	end)
end

-- [[ Core Functional Logic ]] --

local function GetClosestPlayer(maxDist)
	local closest, dist = nil, maxDist or math.huge
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
			local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if mag < dist then
					dist = mag
					closest = plr
				end
			end
		end
	end
	return closest
end

local function ToggleAimbot(state)
	if state then
		Bind("Aimbot", RunService.RenderStepped, function()
			local target = GetClosestPlayer()
			if target and target.Character and target.Character:FindFirstChild("Head") then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
			end
		end)
	else
		Unbind("Aimbot")
	end
end

local function ToggleTriggerbot(state)
	if state then
		Bind("Triggerbot", RunService.Heartbeat, function()
			local target = GetClosestPlayer(50) -- 50px radius from center
			if target then
				local char = LocalPlayer.Character
				if char then
					local tool = char:FindFirstChildOfClass("Tool")
					if tool then tool:Activate() end
				end
			end
		end)
	else
		Unbind("Triggerbot")
	end
end

local function ToggleESP(state)
	if state then
		Bind("ESP", RunService.RenderStepped, function()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					if not plr.Character:FindFirstChild("ESPHighlight") then
						local hl = Instance.new("Highlight")
						hl.Name = "ESPHighlight"
						hl.FillColor = Color3.fromRGB(255, 0, 0)
						hl.OutlineColor = Color3.fromRGB(255, 255, 255)
						hl.Parent = plr.Character
					end
				end
			end
		end)
	else
		Unbind("ESP")
		for _, plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChild("ESPHighlight") then
				plr.Character.ESPHighlight:Destroy()
			end
		end
	end
end

local function ToggleNoclip(state)
	if state then
		Bind("Noclip", RunService.Stepped, function()
			local char = LocalPlayer.Character
			if char then
				for _, part in pairs(char:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		Unbind("Noclip")
	end
end

local function ToggleFly(state, speed)
	if state then
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end
		local hrp = char.HumanoidRootPart
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Velocity = Vector3.zero
		bv.Parent = hrp
		
		Bind("Fly", RunService.RenderStepped, function()
			local move = Vector3.zero
			local cam = Workspace.CurrentCamera
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
			bv.Velocity = move.Unit * speed
		end)
	else
		Unbind("Fly")
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local bv = char.HumanoidRootPart:FindFirstChild("BodyVelocity")
			if bv then bv:Destroy() end
		end
	end
end

local function ToggleAutoFire(state)
	if state then
		Bind("AutoFire", RunService.Heartbeat, function()
			local char = LocalPlayer.Character
			if char then
				local tool = char:FindFirstChildOfClass("Tool")
				if tool then tool:Activate() end
			end
		end)
	else
		Unbind("AutoFire")
	end
end

local function ToggleAutoCollect(state, patterns)
	if state then
		Bind("AutoCollect", RunService.Heartbeat, function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				local hrp = char.HumanoidRootPart
				for _, obj in pairs(Workspace:GetDescendants()) do
					if obj:IsA("BasePart") and not obj.Anchored and obj ~= hrp then
						local name = obj.Name:lower()
						for _, pattern in ipairs(patterns) do
							if name:match(pattern) then
								obj.CFrame = hrp.CFrame
								break
							end
						end
					end
				end
			end
		end)
	else
		Unbind("AutoCollect")
	end
end

local function ToggleHitbox(state, size)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart
			if state then
				hrp.Size = Vector3.new(size, size, size)
				hrp.Transparency = 0.5
				hrp.CanCollide = false
			else
				hrp.Size = Vector3.new(2, 2, 1)
				hrp.Transparency = 1
			end
		end
	end
end

local function ToggleInfJump(state)
	if state then
		Bind("InfJump", UserInputService.JumpRequest, function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		Unbind("InfJump")
	end
end

local function TPUp(amount)
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, amount, 0)
	end
end

local function TPClosest()
	local target = GetClosestPlayer()
	local char = LocalPlayer.Character
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
	end
end

local function ToggleBladeBallParry(state)
	if state then
		Bind("BBParry", RunService.Heartbeat, function()
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") then
				for _, obj in pairs(Workspace:GetDescendants()) do
					if obj:IsA("BasePart") and (obj.Name:lower():match("ball") or obj.Name:lower():match("projectile")) then
						local dist = (obj.Position - char.HumanoidRootPart.Position).Magnitude
						if dist < 25 then
							local tool = char:FindFirstChildOfClass("Tool")
							if tool then tool:Activate() end
							task.wait(0.2)
						end
					end
				end
			end
		end)
	else
		Unbind("BBParry")
	end
end

local function ToggleVehicleFly(state, speed)
	if state then
		Bind("VehicleFly", RunService.Heartbeat, function()
			local char = LocalPlayer.Character
			local seat = char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart
			if seat and seat.Parent and seat.Parent:FindFirstChild("PrimaryPart") then
				local bv = seat.Parent.PrimaryPart:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				bv.Parent = seat.Parent.PrimaryPart
				local cam = Workspace.CurrentCamera
				local move = Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
				bv.Velocity = move.Unit * speed
			end
		end)
	else
		Unbind("VehicleFly")
	end
end

-- [[ Game Configuration & Generation ]] --
local GameListData = {
	"Arsenal", "Rivals", "Hypershot", "Jailbreak", "Combat Arena", 
	"Steal a Brainrot", "Murder Mystery 2", "Blade Ball", "Tower of Hell", 
	"Da Hood", "Natural Disasters Survival", "One Tap", "Bee Swarm Simulator", 
	"Flee the Facility", "Grow a Garden", "Bloxstrike", "Break Your Bones", 
	"Slime RNG"
}

local function BuildGameWindow(gameName)
	local Frame, Scroll, CloseBtn, BackBtn = Hub.CreateWindow(gameName .. " - Test Suite")
	Windows[gameName] = Frame
	
	CloseBtn.MouseButton1Click:Connect(function() Frame.Visible = false end)
	BackBtn.MouseButton1Click:Connect(function()
		Frame.Visible = false
		Windows.Main.Visible = true
	end)

	-- Universal Basic Movement Buttons
	Hub.AddToggle(Scroll, "Speed (32/16)", function(state)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = state and 32 or 16 end
	end)
	Hub.AddToggle(Scroll, "Jump Power (120/50)", function(state)
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = state and 120 or 50 end
	end)
	Hub.AddButton(Scroll, "Reset Character", function()
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then char.Humanoid.Health = 0 end
	end)

	-- Game-Specific Logic Routing
	if gameName == "Arsenal" or gameName == "Rivals" or gameName == "Hypershot" or gameName == "Combat Arena" or gameName == "One Tap" or gameName == "Bloxstrike" then
		Hub.AddToggle(Scroll, "Aimbot (Camera Lock)", ToggleAimbot)
		Hub.AddToggle(Scroll, "Triggerbot (Auto-Fire in Crosshair)", ToggleTriggerbot)
		Hub.AddToggle(Scroll, "Player ESP", ToggleESP)
		Hub.AddToggle(Scroll, "Hitbox Expander (Size 5)", function(state) ToggleHitbox(state, 5) end)
		Hub.AddToggle(Scroll, "Infinite Jump", ToggleInfJump)

	elseif gameName == "Blade Ball" then
		Hub.AddToggle(Scroll, "Auto Parry (Distance < 25)", ToggleBladeBallParry)
		Hub.AddToggle(Scroll, "Player ESP", ToggleESP)
		Hub.AddToggle(Scroll, "Hitbox Expander (Size 10)", function(state) ToggleHitbox(state, 10) end)
		Hub.AddToggle(Scroll, "Infinite Jump", ToggleInfJump)

	elseif gameName == "Tower of Hell" or gameName == "Natural Disasters Survival" then
		Hub.AddToggle(Scroll, "Noclip", ToggleNoclip)
		Hub.AddToggle(Scroll, "Fly (WASD + Space/Ctrl)", function(state) ToggleFly(state, 60) end)
		Hub.AddToggle(Scroll, "Infinite Jump", ToggleInfJump)
		Hub.AddButton(Scroll, "TP Up 500 Studs", function() TPUp(500) end)

	elseif gameName == "Bee Swarm Simulator" or gameName == "Slime RNG" or gameName == "Grow a Garden" or gameName == "Steal a Brainrot" or gameName == "Break Your Bones" then
		Hub.AddToggle(Scroll, "Auto Clicker (Tool Activate)", ToggleAutoFire)
		Hub.AddToggle(Scroll, "Auto Collect (Pollen, Drops, Orbs, Coins)", function(state)
			ToggleAutoCollect(state, {"pollen", "drop", "orb", "coin", "item", "brainrot", "slime", "token"})
		end)
		Hub.AddToggle(Scroll, "Fly (WASD + Space/Ctrl)", function(state) ToggleFly(state, 80) end)
		Hub.AddToggle(Scroll, "Infinite Jump", ToggleInfJump)

	elseif gameName == "Da Hood" then
		Hub.AddToggle(Scroll, "Aimlock (Camera)", ToggleAimbot)
		Hub.AddToggle(Scroll, "Triggerbot (Auto-Fire)", ToggleTriggerbot)
		Hub.AddToggle(Scroll, "Player ESP", ToggleESP)
		Hub.AddToggle(Scroll, "Hitbox Expander (Size 5)", function(state) ToggleHitbox(state, 5) end)
		Hub.AddButton(Scroll, "TP to Closest Player", TPClosest)

	elseif gameName == "Murder Mystery 2" or gameName == "Flee the Facility" then
		Hub.AddToggle(Scroll, "Player ESP (See Everyone)", ToggleESP)
		Hub.AddToggle(Scroll, "Noclip", ToggleNoclip)
		Hub.AddButton(Scroll, "TP to Closest Player", TPClosest)

	elseif gameName == "Jailbreak" then
		Hub.AddToggle(Scroll, "Noclip (Prison Break)", ToggleNoclip)
		Hub.AddToggle(Scroll, "Player ESP (Cops/Robbers)", ToggleESP)
		Hub.AddToggle(Scroll, "Vehicle Fly (WASD - Speed 150)", function(state) ToggleVehicleFly(state, 150) end)
		Hub.AddToggle(Scroll, "Infinite Jump", ToggleInfJump)
	end
end

-- [[ Main Menu Setup ]] --
local MainFrame, MainScroll, MainClose = Hub.CreateWindow("Test Hub - Main Menu")
Windows.Main = MainFrame
MainFrame.Visible = true

MainClose.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

for _, gameName in ipairs(GameListData) do
	Hub.AddButton(MainScroll, gameName, function()
		if not Windows[gameName] then BuildGameWindow(gameName) end
		MainFrame.Visible = false
		Windows[gameName].Visible = true
	end)
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
		local anyVisible = false
		for _, v in pairs(Windows) do if v.Visible then anyVisible = true; break end end
		if anyVisible then
			for _, v in pairs(Windows) do v.Visible = false end
		else
			Windows.Main.Visible = true
		end
	end
end)

print("Full Studio Test Hub loaded. Press Right Ctrl to hide/show.")
