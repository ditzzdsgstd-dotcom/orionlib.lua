-- YoxanXHub | Hypershot Gunfight - Silent Aim V2+ (Part 1/5 FINAL)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub | Hypershot Gunfight V2+",
	HidePremium = false,
	SaveConfig = false,
	IntroEnabled = true,
	IntroText = "YoxanXHub V2+ Loaded"
})

getgenv().YoxanXSettings = {
	Enabled = true,
	HeadshotOnly = true,
	AutoFire = true,
	Prediction = true,
	IgnoreDowned = true,
	InvisibleBypass = true,
	Wallbang = true,
	AntiOverkill = true,
	SmartWait = 0.05,
	TeamCheck = false,
	VisibleOnly = true,
	MaxDistance = true,
	StickyLock = true,
	HPFilter = true,
	FallbackHitPart = true,
	CrosshairLockIcon = true,
	ESPEnabled = true,
	DebugInfo = true,
	SilentMode = false,
	AutoPingAdjust = true,
	WallCheck = true
}

local Main = Window:MakeTab({
	Name = "Silent Aim",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Main:AddToggle({Name = "Enable Silent Aim", Default = true, Callback = function(v) YoxanXSettings.Enabled = v end})
Main:AddToggle({Name = "Headshot Only", Default = true, Callback = function(v) YoxanXSettings.HeadshotOnly = v end})
Main:AddToggle({Name = "Team Check", Default = false, Callback = function(v) YoxanXSettings.TeamCheck = v end})
Main:AddToggle({Name = "Visible Only Target", Default = true, Callback = function(v) YoxanXSettings.VisibleOnly = v end})
Main:AddToggle({Name = "Max Distance Limit (500 studs)", Default = true, Callback = function(v) YoxanXSettings.MaxDistance = v end})
Main:AddToggle({Name = "Sticky Lock-On", Default = true, Callback = function(v) YoxanXSettings.StickyLock = v end})
Main:AddToggle({Name = "Target HP Filter", Default = true, Callback = function(v) YoxanXSettings.HPFilter = v end})
Main:AddToggle({Name = "Fallback HitPart (If head not visible)", Default = true, Callback = function(v) YoxanXSettings.FallbackHitPart = v end})

local Visual = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://6034509993",
	PremiumOnly = false
})

Visual:AddToggle({Name = "Enable ESP", Default = true, Callback = function(v) YoxanXSettings.ESPEnabled = v end})
Visual:AddToggle({Name = "Crosshair Lock Icon", Default = true, Callback = function(v) YoxanXSettings.CrosshairLockIcon = v end})
Visual:AddToggle({Name = "Debug Info / FPS Tracker", Default = true, Callback = function(v) YoxanXSettings.DebugInfo = v end})

local Adv = Window:MakeTab({
	Name = "Advanced",
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

Adv:AddToggle({Name = "Silent Mode (Mute shooting sounds)", Default = false, Callback = function(v) YoxanXSettings.SilentMode = v end})
Adv:AddToggle({Name = "Auto Ping Adjuster", Default = true, Callback = function(v) YoxanXSettings.AutoPingAdjust = v end})
Adv:AddToggle({Name = "3D WallCheck Raycast", Default = true, Callback = function(v) YoxanXSettings.WallCheck = v end})
Adv:AddSlider({Name = "Smart Wait Delay", Min = 0.02, Max = 0.15, Default = 0.05, Increment = 0.01, ValueName = "s", Callback = function(v) YoxanXSettings.SmartWait = v end})

-- YoxanXHub | Silent Aim V2+ (Part 2/5) - Logic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Settings = getgenv().YoxanXSettings or {}

-- Utilities
local function IsVisible(target)
	if not Settings.VisibleOnly then return true end
	local origin = Camera.CFrame.Position
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character or {}}
	local ray = workspace:Raycast(origin, (target.Position - origin).Unit * 1000, rayParams)
	return not ray or ray.Instance:IsDescendantOf(target.Parent)
end

local function IsOnTeam(player)
	return Settings.TeamCheck and player.Team == LocalPlayer.Team
end

local function GetDistanceFromCamera(pos)
	return (Camera.CFrame.Position - pos).Magnitude
end

local function GetClosestTarget()
	local closest, closestDistance = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			if not IsOnTeam(player) then
				local head = player.Character:FindFirstChild("Head")
				if head and IsVisible(head) then
					local distance = GetDistanceFromCamera(head.Position)
					if Settings.MaxDistance and distance > 500 then continue end
					if distance < closestDistance then
						closest, closestDistance = player, distance
					end
				end
			end
		end
	end
	return closest
end

local function AimAt(part)
	if not part then return end
	local args = {
		[1] = part.Position + Vector3.new(0, 0.05, 0) -- slight offset for head
	}
	mousemoverel(0,0)
end

-- Fire function
local function FireAt(part)
	if not part then return end
	local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
	if not tool then return end
	local fireEvent = tool:FindFirstChildWhichIsA("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteFunction")
	if fireEvent then
		if Settings.WallCheck and not IsVisible(part) and not Settings.Wallbang then return end
		fireEvent:FireServer(part.Position)
	end
end

-- Main loop
RunService.RenderStepped:Connect(function()
	if not Settings.Enabled then return end
	local target = GetClosestTarget()
	if target and target.Character then
		local head = target.Character:FindFirstChild("Head")
		local targetPart = head

		if Settings.FallbackHitPart and not head then
			targetPart = target.Character:FindFirstChild("HumanoidRootPart")
		end

		if targetPart then
			if Settings.HeadshotOnly then
				AimAt(targetPart)
			end
			if Settings.AutoFire then
				FireAt(targetPart)
			end
		end
	end
end)

-- YoxanXHub | Silent Aim V2+ (Part 3/5) - ESP & Visuals
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Settings = getgenv().YoxanXSettings or {}

-- ESP Table
local ESP = {}

local function createESP(player)
	if ESP[player] then return end
	local box = Drawing.new("Square")
	box.Color = Color3.new(1, 1, 1)
	box.Thickness = 2
	box.Filled = false
	box.Visible = false

	local name = Drawing.new("Text")
	name.Size = 14
	name.Color = Color3.new(1, 1, 1)
	name.Center = true
	name.Outline = true
	name.Visible = false

	ESP[player] = {Box = box, Name = name}
end

local function removeESP(player)
	if ESP[player] then
		for _, obj in pairs(ESP[player]) do
			obj:Remove()
		end
		ESP[player] = nil
	end
end

local function updateESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
			createESP(player)
			local pos, onscreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
			if onscreen and Settings.ESPEnabled then
				local size = 3
				local box = ESP[player].Box
				box.Size = Vector2.new(60, 90)
				box.Position = Vector2.new(pos.X - 30, pos.Y - 45)
				box.Visible = true

				local name = ESP[player].Name
				name.Text = player.Name
				name.Position = Vector2.new(pos.X, pos.Y - 55)
				name.Visible = true
			else
				ESP[player].Box.Visible = false
				ESP[player].Name.Visible = false
			end
		else
			removeESP(player)
		end
	end
end

-- Crosshair Lock Icon
local lockIcon = Drawing.new("Text")
lockIcon.Size = 18
lockIcon.Center = true
lockIcon.Outline = true
lockIcon.Visible = false
lockIcon.Text = "LOCK"
lockIcon.Color = Color3.fromRGB(255, 0, 0)

-- FPS & Debug
local fpsText = Drawing.new("Text")
fpsText.Size = 14
fpsText.Position = Vector2.new(10, 10)
fpsText.Color = Color3.new(1, 1, 1)
fpsText.Outline = true
fpsText.Visible = false

local last = tick()
local frames = 0
local fps = 0

RunService.RenderStepped:Connect(function()
	if Settings.ESPEnabled then
		updateESP()
	end

	if Settings.CrosshairLockIcon then
		local closest = getgenv().YoxanX_Target
		if closest and closest.Character and closest.Character:FindFirstChild("Head") then
			local head = closest.Character.Head.Position
			local screenPos, onScreen = Camera:WorldToViewportPoint(head)
			if onScreen then
				lockIcon.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
				lockIcon.Visible = true
			else
				lockIcon.Visible = false
			end
		else
			lockIcon.Visible = false
		end
	else
		lockIcon.Visible = false
	end

	if Settings.DebugInfo then
		frames += 1
		if tick() - last >= 1 then
			fps = frames
			frames = 0
			last = tick()
		end
		fpsText.Text = "FPS: " .. fps
		fpsText.Visible = true
	else
		fpsText.Visible = false
	end
end)

-- Cleanup on leave
Players.PlayerRemoving:Connect(removeESP)

-- YoxanXHub | Silent Aim V2+ (Part 4/5) - Prediction, WallCheck, Anti Overkill
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Settings = getgenv().YoxanXSettings or {}

-- Ping Monitor
local function getPing()
	local net = Stats:FindFirstChild("Performance") or Stats
	local pingStat = net:FindFirstChild("Ping") or net:FindFirstChild("Data Ping")
	if pingStat and pingStat:GetValue() then
		return tonumber(pingStat:GetValue())
	end
	return 50 -- fallback
end

-- Prediction Calculator
local function applyPrediction(target)
	local ping = getPing()
	local delay = (ping / 1000) + (Settings.AutoPingAdjust and Settings.SmartWait or 0.05)
	local part = target:FindFirstChild("Head")
	if not part then return nil end

	local root = target:FindFirstChild("HumanoidRootPart")
	if not root then return part.Position end

	local velocity = root.Velocity
	local predicted = part.Position + (velocity * delay)
	return predicted
end

-- WallCheck Logic
local function canShootThrough(part)
	if not Settings.WallCheck then return true end
	local origin = Camera.CFrame.Position
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	local ray = workspace:Raycast(origin, (part.Position - origin), rayParams)
	return not ray or ray.Instance:IsDescendantOf(part.Parent) or Settings.Wallbang
end

-- Overkill Preventer
local LastTarget = nil
local function isDead(target)
	return target and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health <= 0
end

-- Hook from previous logic
RunService.RenderStepped:Connect(function()
	if not Settings.Enabled then return end

	local target = getgenv().YoxanX_Target or nil
	if isDead(LastTarget) and Settings.AntiOverkill then
		getgenv().YoxanX_Target = nil
		LastTarget = nil
		return
	end

	if target and target.Character and target.Character:FindFirstChild("Head") then
		local predictedPos = applyPrediction(target.Character)
		if predictedPos then
			if canShootThrough(target.Character.Head) then
				if Settings.HeadshotOnly and Settings.AutoFire then
					local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
					local fire = tool and (tool:FindFirstChildWhichIsA("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteFunction"))
					if fire then
						fire:FireServer(predictedPos)
					end
				end
			end
		end
		LastTarget = target
	end
end)

-- YoxanXHub | Silent Aim V2+ (Part 5/5) - Final Lock Logic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Settings = getgenv().YoxanXSettings or {}
getgenv().YoxanX_Target = nil

-- Helper: Priority Logic
local function getPriorityTarget()
	local closest, closestDist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
			local hp = player.Character.Humanoid.Health
			if hp <= 0 then continue end
			if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
			if Settings.HPFilter and hp < 10 then continue end

			local head = player.Character.Head
			local screenPos, visible = Camera:WorldToViewportPoint(head.Position)
			if not visible and Settings.VisibleOnly then continue end

			local dist = (Camera.CFrame.Position - head.Position).Magnitude
			if Settings.MaxDistance and dist > 500 then continue end

			if dist < closestDist then
				closest = player
				closestDist = dist
			end
		end
	end
	return closest
end

-- Sticky Lock System
local function lockOn()
	local target = getgenv().YoxanX_Target
	if Settings.StickyLock and target and target.Character and target.Character:FindFirstChild("Humanoid") then
		if target.Character.Humanoid.Health <= 0 then
			getgenv().YoxanX_Target = nil
		end
	else
		getgenv().YoxanX_Target = getPriorityTarget()
	end
end

-- Final Lock Loop
RunService.RenderStepped:Connect(function()
	if not Settings.Enabled then return end
	lockOn()
end)

-- Safety Clean
Players.PlayerRemoving:Connect(function(player)
	if player == getgenv().YoxanX_Target then
		getgenv().YoxanX_Target = nil
	end
end)

OrionLib:MakeNotification({
	Name = "YoxanXHub V2 Loaded",
	Content = "Ready to use",
	Image = "rbxassetid://4483345998",
	Time = 5
})
