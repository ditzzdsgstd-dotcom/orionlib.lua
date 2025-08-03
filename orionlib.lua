-- YoxanXHub | Hypershot Gunfight - Silent Aim V3+ (Part 1/5)
-- OrionLib UI Setup (Mobile Friendly)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub | Hypershot Gunfight V3+",
	HidePremium = false,
	SaveConfig = false,
	IntroEnabled = true,
	IntroText = "YoxanXHub V3+ Loaded"
})

-- Core Settings Table
getgenv().YoxanXSettings = {
	Enabled = true,
	HeadshotOnly = true,
	AutoFire = true,
	Prediction = true,
	SmartWait = 0.05,
	IgnoreDowned = true,
	InvisibleBypass = true,
	Wallbang = true,
	AntiOverkill = true,

	-- Toggle via UI
	TeamCheck = false,
	VisibleOnly = true,
	MaxDistance = true,
	StickyLock = true,
	MultiTarget = false,
	HPFilter = true,
	FallbackHitPart = true,
	ESPEnabled = true,
	DebugInfo = true,
	CrosshairLockIcon = true,
	NameESPColor = true,
	TargetFreezeBypass = true,
	HitmarkerEffect = true,
	AutoPingAdjust = true,
	WallCheck = true,
	AntiPartShield = true,
	AutoLeaveOnMod = false
}

-- Main Tab
local Main = Window:MakeTab({
	Name = "Silent Aim",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Main:AddToggle({Name = "Enable Silent Aim", Default = true, Callback = function(v) YoxanXSettings.Enabled = v end})
Main:AddToggle({Name = "Headshot Only", Default = true, Callback = function(v) YoxanXSettings.HeadshotOnly = v end})
Main:AddToggle({Name = "Auto Fire", Default = true, Callback = function(v) YoxanXSettings.AutoFire = v end})
Main:AddToggle({Name = "Visible Only Target", Default = true, Callback = function(v) YoxanXSettings.VisibleOnly = v end})
Main:AddToggle({Name = "Max Distance Limit (500)", Default = true, Callback = function(v) YoxanXSettings.MaxDistance = v end})
Main:AddToggle({Name = "Sticky Lock-On", Default = true, Callback = function(v) YoxanXSettings.StickyLock = v end})
Main:AddToggle({Name = "Multi Target Mode", Default = false, Callback = function(v) YoxanXSettings.MultiTarget = v end})
Main:AddToggle({Name = "Ignore Dead / Downed", Default = true, Callback = function(v) YoxanXSettings.IgnoreDowned = v end})
Main:AddToggle({Name = "Target HP Filter (>10)", Default = true, Callback = function(v) YoxanXSettings.HPFilter = v end})
Main:AddToggle({Name = "Fallback HitPart", Default = true, Callback = function(v) YoxanXSettings.FallbackHitPart = v end})
Main:AddToggle({Name = "Target Freeze Bypass", Default = true, Callback = function(v) YoxanXSettings.TargetFreezeBypass = v end})
Main:AddToggle({Name = "Anti Part Shield (Forcefields)", Default = true, Callback = function(v) YoxanXSettings.AntiPartShield = v end})
Main:AddToggle({Name = "Auto Leave on Mod Join", Default = false, Callback = function(v) YoxanXSettings.AutoLeaveOnMod = v end})

-- Visual Tab
local Visual = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://6034509993",
	PremiumOnly = false
})

Visual:AddToggle({Name = "Enable ESP", Default = true, Callback = function(v) YoxanXSettings.ESPEnabled = v end})
Visual:AddToggle({Name = "Name ESP by Team Color", Default = true, Callback = function(v) YoxanXSettings.NameESPColor = v end})
Visual:AddToggle({Name = "Crosshair Lock Icon", Default = true, Callback = function(v) YoxanXSettings.CrosshairLockIcon = v end})
Visual:AddToggle({Name = "Hitmarker Effect", Default = true, Callback = function(v) YoxanXSettings.HitmarkerEffect = v end})
Visual:AddToggle({Name = "Debug Info / FPS", Default = true, Callback = function(v) YoxanXSettings.DebugInfo = v end})

-- Advanced Tab
local Adv = Window:MakeTab({
	Name = "Advanced",
	Icon = "rbxassetid://6031280882",
	PremiumOnly = false
})

Adv:AddToggle({Name = "Prediction", Default = true, Callback = function(v) YoxanXSettings.Prediction = v end})
Adv:AddToggle({Name = "Auto Ping Adjuster", Default = true, Callback = function(v) YoxanXSettings.AutoPingAdjust = v end})
Adv:AddToggle({Name = "WallCheck 3D Raycast", Default = true, Callback = function(v) YoxanXSettings.WallCheck = v end})
Adv:AddToggle({Name = "Wallbang (Auto Fire Through Wall)", Default = true, Callback = function(v) YoxanXSettings.Wallbang = v end})
Adv:AddToggle({Name = "Invisible Target Bypass", Default = true, Callback = function(v) YoxanXSettings.InvisibleBypass = v end})
Adv:AddToggle({Name = "Anti Overkill", Default = true, Callback = function(v) YoxanXSettings.AntiOverkill = v end})
Adv:AddSlider({
	Name = "Smart Wait Delay",
	Min = 0.02,
	Max = 0.15,
	Default = 0.05,
	Increment = 0.01,
	ValueName = "s",
	Callback = function(v)
		YoxanXSettings.SmartWait = v
	end
})

-- YoxanXHub | Silent Aim V3+ (Part 2/5) - Target Priority & Multi Target
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Settings = getgenv().YoxanXSettings or {}
getgenv().YoxanX_Targets = {}

local function isValidTarget(player)
	if player == LocalPlayer or not player.Character then return false end
	local char = player.Character
	local head = char:FindFirstChild("Head")
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not head or not root or not hum then return false end
	if hum.Health <= 0 then return false end
	if Settings.TeamCheck and player.Team == LocalPlayer.Team then return false end
	if Settings.HPFilter and hum.Health < 10 then return false end
	if Settings.AntiPartShield and (char:FindFirstChild("ForceField") or char:FindFirstChildWhichIsA("ForceField")) then return false end
	if not Camera:WorldToViewportPoint(head.Position).Z > 0 then return false end
	if Settings.MaxDistance and (Camera.CFrame.Position - head.Position).Magnitude > 500 then return false end
	return true
end

local function getTargetList()
	local result = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if isValidTarget(player) then
			table.insert(result, player)
		end
	end
	return result
end

local function getClosestTarget()
	local closest, closestDist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if isValidTarget(player) then
			local head = player.Character.Head
			local screenPos, visible = Camera:WorldToViewportPoint(head.Position)
			if not visible and Settings.VisibleOnly then continue end
			local dist = (Camera.CFrame.Position - head.Position).Magnitude
			if dist < closestDist then
				closest = player
				closestDist = dist
			end
		end
	end
	return closest
end

-- Main Lock Function
local function updateTargets()
	if Settings.MultiTarget then
		getgenv().YoxanX_Targets = getTargetList()
	else
		local single = getClosestTarget()
		getgenv().YoxanX_Targets = single and {single} or {}
	end
end

-- Auto Refresh Targets
game:GetService("RunService").RenderStepped:Connect(function()
	if not Settings.Enabled then return end
	updateTargets()
end)

-- YoxanXHub | Silent Aim V3+ (Part 3/5) - Fire Logic & Prediction
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Settings = getgenv().YoxanXSettings or {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Helper: Get Head Position with Prediction
local function predictTarget(target)
	local char = target.Character
	local head = char and char:FindFirstChild("Head")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not head or not hrp then return nil end

	local velocity = hrp.Velocity
	local distance = (Camera.CFrame.Position - head.Position).Magnitude
	local pingAdjust = Settings.AutoPingAdjust and (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000) or 0
	local time = distance / 200 -- bullet speed assumed 200
	local predicted = head.Position + (velocity * (Settings.Prediction and (time + pingAdjust) or 0))
	return predicted
end

-- Helper: Raycast WallCheck
local function canHit(position)
	if not Settings.WallCheck then return true end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	local result = workspace:Raycast(Camera.CFrame.Position, (position - Camera.CFrame.Position).Unit * 1000, rayParams)
	if not result then return true end
	if result.Instance.Transparency >= 0.4 or result.Instance:IsA("Decal") or result.Instance.CanCollide == false then
		return true
	end
	return Settings.Wallbang
end

-- Fire Simulation (for supported games)
local function fireAt(position)
	local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
	if not tool then return end
	local fireEvent = tool:FindFirstChildWhichIsA("RemoteEvent") or tool:FindFirstChildWhichIsA("RemoteFunction")
	if fireEvent then
		pcall(function()
			fireEvent:FireServer(position)
		end)
	end
end

-- Main Fire Logic
RunService.Heartbeat:Connect(function()
	if not Settings.Enabled or not Settings.AutoFire then return end
	for _, target in ipairs(getgenv().YoxanX_Targets) do
		local char = target.Character
		if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then continue end
		if Settings.IgnoreDowned and char:FindFirstChild("Downed") then continue end
		if Settings.InvisibleBypass == false and not char:FindFirstChild("Head"):IsDescendantOf(workspace) then continue end

		local predicted = predictTarget(target)
		if predicted and canHit(predicted) then
			fireAt(predicted)
			if not Settings.MultiTarget then break end
			wait(Settings.SmartWait or 0.05)
		end
	end
end)

-- YoxanXHub | Silent Aim V3+ (Part 4/5) - Visuals & Priority
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Settings = getgenv().YoxanXSettings or {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function teamColor(player)
	if player.Team and player.Team.TeamColor then
		return player.Team.TeamColor.Color
	end
	return Color3.new(1, 1, 1)
end

-- ESP Name Color + Hitmarker
local function showHitmarker(text)
	if not Settings.HitmarkerEffect then return end
	local gui = Instance.new("BillboardGui", Camera)
	gui.Adornee = nil
	gui.Size = UDim2.new(0, 200, 0, 50)
	gui.StudsOffset = Vector3.new(0, 0, -2)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text or "HIT"
	label.TextColor3 = Color3.new(1, 0, 0)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true

	game.Debris:AddItem(gui, 0.35)
end

-- ESP Tags (simple for mobile)
local function drawESP(player)
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end
	local tag = head:FindFirstChild("YoxanX_Tag")
	if tag then tag:Destroy() end

	local billboard = Instance.new("BillboardGui", head)
	billboard.Name = "YoxanX_Tag"
	billboard.Size = UDim2.new(0, 100, 0, 20)
	billboard.Adornee = head
	billboard.AlwaysOnTop = true

	local text = Instance.new("TextLabel", billboard)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.Text = player.Name
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = Settings.NameESPColor and teamColor(player) or Color3.new(1, 1, 1)

	game.Debris:AddItem(billboard, 2)
end

-- Target Sorting (by distance or HP)
local function sortTargets(targets)
	table.sort(targets, function(a, b)
		local charA, charB = a.Character, b.Character
		if not charA or not charB then return false end
		local hpA = charA:FindFirstChild("Humanoid") and charA.Humanoid.Health or 0
		local hpB = charB:FindFirstChild("Humanoid") and charB.Humanoid.Health or 0
		local distA = (Camera.CFrame.Position - charA.Head.Position).Magnitude
		local distB = (Camera.CFrame.Position - charB.Head.Position).Magnitude
		return (hpA < hpB) or (distA < distB)
	end)
	return targets
end

-- Auto Retarget if Dead
local function cleanupAndRetarget()
	local cleaned = {}
	for _, target in ipairs(getgenv().YoxanX_Targets) do
		local char = target.Character
		if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
			table.insert(cleaned, target)
		end
	end
	getgenv().YoxanX_Targets = sortTargets(cleaned)
end

-- Main Display Handler
RunService.RenderStepped:Connect(function()
	if not Settings.ESPEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			drawESP(player)
		end
	end
end)

-- Retarget Monitor
RunService.Heartbeat:Connect(function()
	if Settings.Enabled then
		cleanupAndRetarget()
	end
end)

-- YoxanXHub | Silent Aim V3+ (Part 5/5 FINAL) - Anti Mod, Spectator, Finishing
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Settings = getgenv().YoxanXSettings or {}
local RunService = game:GetService("RunService")
local Mods = {"ADMIN", "MOD", "STAFF", "OWNER", "YT", "⚡"} -- Add more if needed

-- Auto Leave on Mod Join
Players.PlayerAdded:Connect(function(player)
	if not Settings.AutoLeaveOnMod then return end
	for _, name in ipairs(Mods) do
		if string.find(string.upper(player.Name), name) then
			OrionLib:MakeNotification({
				Name = "YoxanXHub Alert",
				Content = "Moderator Detected! Leaving...",
				Image = "rbxassetid://4483345998",
				Time = 4
			})
			wait(2)
			game:Shutdown()
			return
		end
	end
end)

-- Spectator Detection (basic alert)
RunService.RenderStepped:Connect(function()
	if not Settings.DebugInfo then return end
	local spectators = 0
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and not p.Character then
			spectators += 1
		end
	end
	if spectators >= 1 then
		OrionLib:MakeNotification({
			Name = "YoxanXHub Notice",
			Content = tostring(spectators) .. " people spectating you!",
			Image = "rbxassetid://4483345998",
			Time = 4
		})
	end
end)

-- Final Notification
OrionLib:MakeNotification({
	Name = "YoxanXHub V3+ Fully Loaded",
	Content = "Silent Aim + ESP Ready",
	Image = "rbxassetid://4483345998",
	Time = 5
})

OrionLib:MakeNotification({
	Name = "YoxanXHub V3+ Loaded",
	Content = "Ready to Use",
	Image = "rbxassetid://4483345998",
	Time = 5
})
