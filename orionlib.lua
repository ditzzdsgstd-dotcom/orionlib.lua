-- YoxanXHub V3.5 - Part 1/5 (UI Full Setup) [Mobile Paste OK]
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub | Hypershot Gunfight V3.5",
	HidePremium = false,
	SaveConfig = false,
	IntroEnabled = true,
	IntroText = "YoxanXHub V3.5 Loaded"
})

getgenv().YoxanXSettings = {
	Enabled = false,
	HeadshotOnly = false,
	StickyLock = false,
	IgnoreShielded = false,
	VisibleOnly = true,
	MaxDistance = true,
	WallCheck = true,
	SmartWait = 0.05,
	ESPEnabled = true,
	HitEffect = true,
	HitText = true,
	AntiRecoil = true,

	-- Auto ON
	AutoFire = true,
	Prediction = true,
	IgnoreDowned = true,
	InvisibleBypass = true,
	AutoPingAdjust = true,
	AntiOverkill = true,
	Wallbang = true,
	MultiTarget = true,
	CrosshairIcon = true,
	FreezeBypass = true,
	SilentMode = true,
	ModLeave = true
}

local Tab = Window:MakeTab({
	Name = "Silent Aim",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddToggle({
	Name = "Enable Silent Aim",
	Default = false,
	Callback = function(val)
		YoxanXSettings.Enabled = val
	end
})

Tab:AddToggle({
	Name = "Headshot Only",
	Default = false,
	Callback = function(val)
		YoxanXSettings.HeadshotOnly = val
	end
})

Tab:AddToggle({
	Name = "Sticky Lock-On",
	Default = false,
	Callback = function(val)
		YoxanXSettings.StickyLock = val
	end
})

Tab:AddToggle({
	Name = "Ignore Shielded Players",
	Default = false,
	Callback = function(val)
		YoxanXSettings.IgnoreShielded = val
	end
})

Tab:AddToggle({
	Name = "Visible Only Targets",
	Default = true,
	Callback = function(val)
		YoxanXSettings.VisibleOnly = val
	end
})

Tab:AddToggle({
	Name = "Max Distance Limit (500 Studs)",
	Default = true,
	Callback = function(val)
		YoxanXSettings.MaxDistance = val
	end
})

Tab:AddToggle({
	Name = "WallCheck 3D (Raycast)",
	Default = true,
	Callback = function(val)
		YoxanXSettings.WallCheck = val
	end
})

Tab:AddSlider({
	Name = "Smart Delay Between Shots",
	Min = 0.02,
	Max = 0.15,
	Default = 0.05,
	Increment = 0.01,
	ValueName = "s",
	Callback = function(val)
		YoxanXSettings.SmartWait = val
	end
})

local VisualTab = Window:MakeTab({
	Name = "Visuals",
	Icon = "rbxassetid://6034509993",
	PremiumOnly = false
})

VisualTab:AddToggle({
	Name = "Enable ESP (Team Color)",
	Default = true,
	Callback = function(val)
		YoxanXSettings.ESPEnabled = val
	end
})

VisualTab:AddToggle({
	Name = "Bullet Flash Effect",
	Default = true,
	Callback = function(val)
		YoxanXSettings.HitEffect = val
	end
})

VisualTab:AddToggle({
	Name = "Hitmarker Text (Bottom Screen)",
	Default = true,
	Callback = function(val)
		YoxanXSettings.HitText = val
	end
})

VisualTab:AddToggle({
	Name = "Anti Recoil Compensation",
	Default = true,
	Callback = function(val)
		YoxanXSettings.AntiRecoil = val
	end
})

-- YoxanXHub V3.5 - Part 2/5 (Targeting + Prediction Logic)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local function IsVisible(part)
	if not part then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
	return ray == nil or ray.Instance:IsDescendantOf(part.Parent)
end
local function IsShielded(char)
	return char:FindFirstChild("ForceField") or char:FindFirstChild("Shield") or char:FindFirstChild("Bubble")
end
local function IsDowned(char)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health <= 0
end
local function PredictPosition(part, velocity, distance)
	local ping = tonumber(string.match(game:Stats():GetTotalMemoryUsageMb(), "%d+")) or 50
	local speed = 200
	if YoxanXSettings.AutoPingAdjust then
		speed = speed - math.clamp(ping, 0, 200) * 0.3
	end
	local travelTime = distance / speed
	return part.Position + (velocity * travelTime)
end
function GetValidTargets()
	local list = {}
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			if YoxanXSettings.IgnoreShielded and IsShielded(player.Character) then continue end
			if YoxanXSettings.IgnoreDowned and IsDowned(player.Character) then continue end
			local head = player.Character.Head
			if YoxanXSettings.VisibleOnly and not IsVisible(head) then continue end
			if YoxanXSettings.MaxDistance and (head.Position - Camera.CFrame.Position).Magnitude > 500 then continue end
			table.insert(list, player)
		end
	end
	return list
end
function LockClosestTarget()
	local shortestDist = math.huge
	local best = nil
	for _, player in pairs(GetValidTargets()) do
		local head = player.Character:FindFirstChild("Head")
		if head then
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
			if onScreen and dist < shortestDist then
				shortestDist = dist
				best = player
			end
		end
	end
	return best
end
getgenv().YoxanX_Target = nil
RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.Enabled then return end
	local t = getgenv().YoxanX_Target
	if not t or not t.Character or not t.Character:FindFirstChild("Head") then
		local newT = LockClosestTarget()
		if newT then getgenv().YoxanX_Target = newT end
	elseif not YoxanXSettings.StickyLock then
		getgenv().YoxanX_Target = nil
	end
end)

-- YoxanXHub V3.5 - Part 3/5 (Auto Fire, Aimbot, Bullet, Recoil)
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Mouse = game.Players.LocalPlayer:GetMouse()
local LastShot = tick()

function SmartFire(target)
	if not target or not target.Character then return end
	local char = target.Character
	local head = char:FindFirstChild("Head")
	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	local aimPart = (YoxanXSettings.HeadshotOnly and head) or torso or head
	if not aimPart then return end
	local dist = (Camera.CFrame.Position - aimPart.Position).Magnitude
	local predicted = YoxanXSettings.Prediction and PredictPosition(aimPart, aimPart.Velocity, dist) or aimPart.Position

	if YoxanXSettings.WallCheck then
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		rayParams.FilterDescendantsInstances = {Camera, game.Players.LocalPlayer.Character}
		local result = workspace:Raycast(Camera.CFrame.Position, (predicted - Camera.CFrame.Position).Unit * dist, rayParams)
		if result and not result.Instance:IsDescendantOf(char) then return end
	end

	if tick() - LastShot < YoxanXSettings.SmartWait then return end
	LastShot = tick()

	-- Recoil Compensation
	if YoxanXSettings.AntiRecoil then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, predicted)
	end

	-- Silent Fire Simulation
	mouse1click()

	-- Bullet Flash
	if YoxanXSettings.HitEffect then
		local fx = Instance.new("Part")
		fx.Anchored = true
		fx.CanCollide = false
		fx.Material = Enum.Material.Neon
		fx.Size = Vector3.new(0.2, 0.2, 0.2)
		fx.BrickColor = BrickColor.new("Bright red")
		fx.CFrame = CFrame.new(aimPart.Position)
		fx.Parent = workspace
		game.Debris:AddItem(fx, 0.15)
	end

	-- Hitmarker Text
	if YoxanXSettings.HitText then
		local gui = Instance.new("BillboardGui", Camera)
		gui.Size = UDim2.new(0, 100, 0, 40)
		gui.StudsOffset = Vector3.new(0, 2, 0)
		gui.Adornee = aimPart
		gui.AlwaysOnTop = true
		local label = Instance.new("TextLabel", gui)
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "HIT"
		label.TextColor3 = Color3.new(1, 0, 0)
		label.TextStrokeTransparency = 0
		label.TextScaled = true
		game.Debris:AddItem(gui, 0.4)
	end

	-- SilentMode (disable shot sound)
	if YoxanXSettings.SilentMode and char:FindFirstChildOfClass("Humanoid") then
		for _, sfx in pairs(char:GetDescendants()) do
			if sfx:IsA("Sound") and sfx.IsPlaying then
				sfx.Volume = 0
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.Enabled then return end
	if not YoxanXSettings.AutoFire then return end
	local target = getgenv().YoxanX_Target
	if target then SmartFire(target) end
end)

-- YoxanXHub V3.5 - Part 4/5 (ESP, Crosshair, Name Color, Hit FX)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function GetTeamColor(player)
	if player.Team and player.TeamColor then
		return player.TeamColor.Color
	end
	return Color3.new(1, 1, 1)
end

local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "YoxanX_ESP"

function ClearESP()
	for _, obj in ipairs(ESPFolder:GetChildren()) do
		obj:Destroy()
	end
end

function CreateESP(player)
	if not player.Character or not player.Character:FindFirstChild("Head") then return end
	local head = player.Character.Head
	local tag = Instance.new("BillboardGui", ESPFolder)
	tag.Adornee = head
	tag.Size = UDim2.new(0, 100, 0, 30)
	tag.StudsOffset = Vector3.new(0, 2, 0)
	tag.AlwaysOnTop = true
	local name = Instance.new("TextLabel", tag)
	name.Size = UDim2.new(1, 0, 1, 0)
	name.BackgroundTransparency = 1
	name.Text = player.DisplayName or player.Name
	name.TextColor3 = GetTeamColor(player)
	name.TextStrokeTransparency = 0.5
	name.TextScaled = true
end

RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.ESPEnabled then
		ClearESP()
		return
	end
	ClearESP()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
			CreateESP(plr)
		end
	end
end)

-- Crosshair Lock Icon
local cross = Drawing.new("Text")
cross.Text = "🎯"
cross.Size = 32
cross.Visible = false
cross.Center = true
cross.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
cross.Color = Color3.fromRGB(255, 50, 50)

RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.CrosshairIcon then
		cross.Visible = false
		return
	end
	local tgt = getgenv().YoxanX_Target
	if tgt and tgt.Character and tgt.Character:FindFirstChild("Head") then
		cross.Visible = true
	else
		cross.Visible = false
	end
end)

-- YoxanXHub V3.5 - Part 5/5 (Optimizer, Mod Detector, Debug)
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- UI Debug FPS + Lock Status
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "YoxanX_HUD"

local infoFrame = Instance.new("TextLabel", screenGui)
infoFrame.Size = UDim2.new(0, 250, 0, 40)
infoFrame.Position = UDim2.new(0, 10, 0, 10)
infoFrame.BackgroundTransparency = 0.4
infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
infoFrame.TextColor3 = Color3.fromRGB(0, 255, 140)
infoFrame.Font = Enum.Font.GothamBold
infoFrame.TextScaled = true
infoFrame.TextStrokeTransparency = 0.5
infoFrame.Text = "YoxanXHub: Loading..."

RunService.RenderStepped:Connect(function()
	local fps = math.floor(1 / RunService.RenderStepped:Wait())
	local target = getgenv().YoxanX_Target
	local locked = (target and target.Name) or "None"
	infoFrame.Text = "FPS: "..fps.." | Locked: "..locked
end)

-- Auto Leave on Mod Join
local mods = {"Admin", "Mod", "STAFF", "Developer"}
Players.PlayerAdded:Connect(function(player)
	for _, word in ipairs(mods) do
		if string.find(string.lower(player.Name), string.lower(word)) then
			if YoxanXSettings.ModLeave then
				StarterGui:SetCore("SendNotification", {
					Title = "YoxanXHub Alert",
					Text = "Moderator Detected. Leaving...",
					Duration = 4
				})
				wait(2)
				game:Shutdown()
			end
		end
	end
end)

-- Auto Clean Up
game:GetService("CoreGui"):WaitForChild("Orion"):SetAttribute("YoxanX_Loaded", true)
warn("YoxanXHub V3.5 Full Loaded")

-- Part 5 Final Done

OrionLib:MakeNotification({
	Name = "YoxanXHub V3.5 Ready",
	Content = "Main UI Loaded. Toggles available!",
	Image = "rbxassetid://4483345998",
	Time = 5
})
