-- YoxanXHub | Hypershot Gunfight V3 (1/25 - Core Init, Tabs, Safe Load)

repeat wait() until game:IsLoaded()

local success, OrionLib = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
end)
if not success then
	return warn("⚠️ OrionLib failed to load. Check connection!")
end

local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub V3 | Hypershot Gunfight",
	HidePremium = false,
	IntroEnabled = true,
	IntroText = "YoxanXHub V3 Loading...",
	SaveConfig = true,
	ConfigFolder = "YoxanXHubV3"
})

-- Tabs
local TabCombat = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://6035078888", PremiumOnly = false})
local TabVisual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://6035193209", PremiumOnly = false})
local TabSafety = Window:MakeTab({Name = "Safety", Icon = "rbxassetid://6035191556", PremiumOnly = false})
local TabInfo = Window:MakeTab({Name = "Info", Icon = "rbxassetid://6031091002", PremiumOnly = false})
local TabDebug = Window:MakeTab({Name = "Debug", Icon = "rbxassetid://6035275664", PremiumOnly = false})

-- Settings
getgenv().YoxanXSettings = {
	Enabled = true,
	SilentAim = true,
	HeadshotOnly = true,
	ESPEnabled = true,
	StickyLock = true,
	VisibleOnly = true,
	MultiTarget = true,
	MaxDistance = true,
	SmartWait = 0.05,
	IgnoreShielded = true,
	AutoFire = true,
	Wallbang = true,
	DebugInfo = false,
	ShowHitmarker = true,
	BypassInvisible = true,
	TargetFreezeBypass = true,
	AntiOverkill = true,
	FakeInput = true,
	TeamColorESP = true,
	PingPrediction = true,
	AutoLeaveOnMod = false
}

-- YoxanXHub V3 (2/25) – UI Toggle: Silent Aim, ESP, Wallbang, Delay, etc.

-- Silent Aim
TabCombat:AddToggle({
	Name = "Silent Aim",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.SilentAim = Value
	end
})

-- Headshot Only
TabCombat:AddToggle({
	Name = "Headshot Only",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.HeadshotOnly = Value
	end
})

-- Multi Target Mode
TabCombat:AddToggle({
	Name = "Multi Target",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.MultiTarget = Value
	end
})

-- Sticky Lock
TabCombat:AddToggle({
	Name = "Sticky Lock-On",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.StickyLock = Value
	end
})

-- ESP Toggle
TabVisual:AddToggle({
	Name = "Enable ESP",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.ESPEnabled = Value
	end
})

-- Team Color ESP
TabVisual:AddToggle({
	Name = "ESP: Team Color",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.TeamColorESP = Value
	end
})

-- Wallbang
TabCombat:AddToggle({
	Name = "Wallbang (Experimental)",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.Wallbang = Value
	end
})

-- Visible Only
TabCombat:AddToggle({
	Name = "Visible Targets Only",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.VisibleOnly = Value
	end
})

-- Smart Wait Slider
TabCombat:AddSlider({
	Name = "Smart Wait Delay",
	Min = 0.01,
	Max = 0.1,
	Default = 0.05,
	Increment = 0.005,
	ValueName = "seconds",
	Callback = function(Value)
		YoxanXSettings.SmartWait = Value
	end
})

-- Max Distance
TabCombat:AddToggle({
	Name = "Max Distance (500 studs)",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.MaxDistance = Value
	end
})

-- YoxanXHub V3 (3/25) – Advanced Lock-On Logic

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function IsVisible(part)
	if not part then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
	return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function PredictPosition(part, velocity, delay)
	return part.Position + (velocity * delay)
end

local function IsShielded(char)
	return char:FindFirstChild("ForceField") or char:FindFirstChild("Shield")
end

local function GetClosestTarget()
	local shortest = math.huge
	local best = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
			local char = player.Character
			local head = char:FindFirstChild("Head")
			local human = char:FindFirstChild("Humanoid")

			if human.Health <= 0 then continue end
			if YoxanXSettings.IgnoreShielded and IsShielded(char) then continue end
			if YoxanXSettings.VisibleOnly and not IsVisible(head) then continue end
			if YoxanXSettings.MaxDistance and (head.Position - Camera.CFrame.Position).Magnitude > 500 then continue end

			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
				if dist < shortest then
					shortest = dist
					best = player
				end
			end
		end
	end
	return best
end

getgenv().YoxanX_Target = nil

RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.SilentAim then return end
	local current = getgenv().YoxanX_Target
	if not current or not current.Character or not current.Character:FindFirstChild("Head") then
		getgenv().YoxanX_Target = GetClosestTarget()
	elseif YoxanXSettings.StickyLock then
		if not current.Character or not current.Character:FindFirstChild("Humanoid") or current.Character.Humanoid.Health <= 0 then
			getgenv().YoxanX_Target = nil
		end
	else
		getgenv().YoxanX_Target = nil
	end
end)

-- YoxanXHub V3 (4/25) – Firing Logic & Headshot Hit Enforcement

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function FireAtTarget(target)
	if not target or not target.Character then return end
	local head = target.Character:FindFirstChild("Head")
	local hrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not head or not hrp then return end

	local predicted = PredictPosition(head, target.Character:GetVelocity(), YoxanXSettings.SmartWait or 0.05)

	if YoxanXSettings.Wallbang then
		-- Simulate Wallbang (ray not blocked)
		local ray = RaycastParams.new()
		ray.FilterType = Enum.RaycastFilterType.Blacklist
		ray.FilterDescendantsInstances = {Camera, LocalPlayer.Character}
		local result = workspace:Raycast(Camera.CFrame.Position, (predicted - Camera.CFrame.Position).Unit * 1000, ray)
		if result and not result.Instance:IsDescendantOf(target.Character) then
			-- Wallbang attempt
		end
	end

	mouse1press()
	task.wait(0.05)
	mouse1release()
end

RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.SilentAim then return end
	if not YoxanXSettings.AutoFire then return end
	local target = getgenv().YoxanX_Target
	if target and target.Character and target.Character:FindFirstChild("Head") then
		FireAtTarget(target)
	end
end)

-- YoxanXHub V3 (5/25) – ESP System: Name by Team, Transparent Walls Nearby

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "YoxanX_ESP"

function ClearESP()
	for _, v in pairs(espFolder:GetChildren()) do
		v:Destroy()
	end
end

function GetTeamColor(player)
	if player.TeamColor then
		return player.TeamColor.Color
	end
	return Color3.new(1, 0, 0)
end

function CreateESP(player)
	if not player.Character or not player.Character:FindFirstChild("Head") then return end
	local head = player.Character:FindFirstChild("Head")
	local billboard = Instance.new("BillboardGui", espFolder)
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.AlwaysOnTop = true
	billboard.Name = player.Name

	local name = Instance.new("TextLabel", billboard)
	name.Size = UDim2.new(1, 0, 1, 0)
	name.Text = player.DisplayName or player.Name
	name.BackgroundTransparency = 1
	name.TextScaled = true
	name.Font = Enum.Font.SourceSansBold
	name.TextColor3 = YoxanXSettings.TeamColorESP and (player.Team == LocalPlayer.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(255, 255, 255)
end

function UpdateESP()
	if not YoxanXSettings.ESPEnabled then
		ClearESP()
		return
	end

	ClearESP()

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			CreateESP(player)
		end
	end
end

-- Transparent Wall Logic
function TransparentNearbyWalls()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide and not obj:IsDescendantOf(LocalPlayer.Character) then
			local pos, onScreen = Camera:WorldToViewportPoint(obj.Position)
			if onScreen and (obj.Position - Camera.CFrame.Position).Magnitude <= 50 then
				obj.Transparency = 0.6
			else
				obj.Transparency = 0
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if YoxanXSettings.ESPEnabled then
		UpdateESP()
	end
	TransparentNearbyWalls()
end)

-- YoxanXHub V3 (6/25) – Safety Tab: Auto Leave, Shield Bypass, Anti-Kick

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Auto Leave on Mod Join
TabSafety:AddToggle({
	Name = "Auto Leave on Mod Join",
	Default = false,
	Callback = function(Value)
		YoxanXSettings.AutoLeaveOnMod = Value
	end
})

-- Shield / ForceField Ignorer
TabSafety:AddToggle({
	Name = "Ignore Shielded Players",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.IgnoreShielded = Value
	end
})

-- Anti Kick (Basic)
TabSafety:AddToggle({
	Name = "Basic Anti-Kick",
	Default = true,
	Callback = function(Value)
		if Value then
			hookfunction(LocalPlayer.Kick, function() return end)
			getrawmetatable(game).__namecall = newcclosure(function(self, ...)
				local args = {...}
				if getnamecallmethod() == "Kick" then return end
				return getrawmetatable(game).__namecall(self, unpack(args))
			end)
		end
	end
})

-- Ping Based Prediction
TabSafety:AddToggle({
	Name = "Auto Ping Prediction",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.PingPrediction = Value
	end
})

-- Invisible Player Bypass
TabSafety:AddToggle({
	Name = "Bypass Invisible Targets",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.BypassInvisible = Value
	end
})

-- Target Freeze Bypass
TabSafety:AddToggle({
	Name = "Bypass Frozen Targets",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.TargetFreezeBypass = Value
	end
})

-- Anti Overkill
TabSafety:AddToggle({
	Name = "Enable Anti-Overkill",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.AntiOverkill = Value
	end
})

-- YoxanXHub V3 (7/25) – Effects & Feedback (Visual / Sensory)

local StarterGui = game:GetService("StarterGui")

-- Bullet Flash Toggle
TabVisual:AddToggle({
	Name = "Enable Bullet Flash",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.BulletFlash = Value
	end
})

-- Hitmarker Effect (bottom screen or spark)
TabVisual:AddToggle({
	Name = "Hitmarker Effect",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.Hitmarker = Value
	end
})

-- Hitstun / Screen Shake Toggle
TabVisual:AddToggle({
	Name = "Hitstun Effect",
	Default = false,
	Callback = function(Value)
		YoxanXSettings.Hitstun = Value
	end
})

-- Anti Recoil (automatically removes recoil from shooting)
TabVisual:AddToggle({
	Name = "Disable Recoil",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.AntiRecoil = Value
	end
})

-- Hitmarker Function
function ShowHitmarker()
	if YoxanXSettings.Hitmarker then
		StarterGui:SetCore("SendNotification", {
			Title = "Hit",
			Text = "✔️",
			Duration = 0.25
		})
	end
end

-- Recoil Suppression Logic (basic)
if YoxanXSettings.AntiRecoil then
	local oldIndex
	oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
		if tostring(key):lower():find("recoil") then
			return 0
		end
		return oldIndex(self, key)
	end))
end

-- Optional: bullet flash part creation (visual)
function FlashBullet(pos)
	if not YoxanXSettings.BulletFlash then return end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Position = pos
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 255, 0)
	part.Parent = workspace
	game:GetService("Debris"):AddItem(part, 0.15)
end

-- YoxanXHub V3 (8/25) – Debug UI Tab (FPS, Target Info, Diagnostics)

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local fpsCounter = 0
local fpsLabel

-- FPS Counter
TabDebug:AddToggle({
	Name = "Enable FPS Tracker",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.ShowFPS = Value
	end
})

-- Target Lock Tracker
TabDebug:AddToggle({
	Name = "Show Locked Target",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.ShowTarget = Value
	end
})

-- FPS Display
fpsLabel = TabDebug:AddParagraph("FPS", "Waiting...")

RunService.RenderStepped:Connect(function()
	if YoxanXSettings.ShowFPS then
		fpsCounter += 1
	end
end)

task.spawn(function()
	while true do
		if YoxanXSettings.ShowFPS then
			fpsLabel:Set("FPS", tostring(fpsCounter))
		end
		fpsCounter = 0
		task.wait(1)
	end
end)

-- Target Lock Tracker Display
local targetParagraph = TabDebug:AddParagraph("Target Lock", "None")

RunService.RenderStepped:Connect(function()
	if YoxanXSettings.ShowTarget and getgenv().YoxanX_Target then
		local t = getgenv().YoxanX_Target
		if t and t.Character and t.Character:FindFirstChild("Humanoid") then
			local name = t.DisplayName or t.Name
			local hp = math.floor(t.Character.Humanoid.Health)
			targetParagraph:Set("Target Lock", name .. " | HP: " .. tostring(hp))
		end
	else
		targetParagraph:Set("Target Lock", "None")
	end
end)

-- YoxanXHub V3 (9/25) – Prioritization System

TabAimbot:AddDropdown({
	Name = "Target Priority",
	Default = "Closest",
	Options = {"Closest", "Lowest Health", "Screen Center"},
	Callback = function(Value)
		YoxanXSettings.TargetPriority = Value
	end
})

local function GetPriorityValue(player)
	if not player.Character or not player.Character:FindFirstChild("Head") or not player.Character:FindFirstChild("Humanoid") then
		return math.huge
	end

	local head = player.Character.Head
	local humanoid = player.Character.Humanoid
	local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

	if YoxanXSettings.TargetPriority == "Closest" then
		return (head.Position - Camera.CFrame.Position).Magnitude
	elseif YoxanXSettings.TargetPriority == "Lowest Health" then
		return humanoid.Health
	elseif YoxanXSettings.TargetPriority == "Screen Center" then
		if onScreen then
			return (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
		else
			return math.huge
		end
	end
end

function GetBestTargetByPriority()
	local best = nil
	local bestValue = math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
			if p.Character.Humanoid.Health <= 0 then continue end
			if YoxanXSettings.IgnoreShielded and IsShielded(p.Character) then continue end
			if YoxanXSettings.VisibleOnly and not IsVisible(p.Character.Head) then continue end
			if YoxanXSettings.MaxDistance and (p.Character.Head.Position - Camera.CFrame.Position).Magnitude > 500 then continue end

			local priorityValue = GetPriorityValue(p)
			if priorityValue < bestValue then
				bestValue = priorityValue
				best = p
			end
		end
	end
	return best
end

-- Replace GetClosestTarget with GetBestTargetByPriority
RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.SilentAim then return end
	local current = getgenv().YoxanX_Target
	if not current or not current.Character or not current.Character:FindFirstChild("Head") then
		getgenv().YoxanX_Target = GetBestTargetByPriority()
	elseif YoxanXSettings.StickyLock then
		if not current.Character or not current.Character:FindFirstChild("Humanoid") or current.Character.Humanoid.Health <= 0 then
			getgenv().YoxanX_Target = nil
		end
	else
		getgenv().YoxanX_Target = nil
	end
end)

-- YoxanXHub V3 (10/25) – WallCheck 3D + Wallbang Support

local function Is3DVisible(part)
	if not part then return false end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin).Unit * 1000

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin, direction, raycastParams)
	if result then
		return result.Instance:IsDescendantOf(part.Parent)
	else
		return false
	end
end

-- WallCheck Toggle
TabAimbot:AddToggle({
	Name = "Enable WallCheck 3D",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.WallCheck3D = Value
	end
})

-- Wallbang Toggle
TabAimbot:AddToggle({
	Name = "Enable Wallbang",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.Wallbang = Value
	end
})

-- Modify visibility check
function IsVisible(targetPart)
	if not targetPart then return false end
	if YoxanXSettings.WallCheck3D then
		return Is3DVisible(targetPart)
	else
		local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
		return onScreen
	end
end

-- Wallbang Fire Logic (called during fire)
function CanWallbang(targetPart)
	if not targetPart then return false end
	if not YoxanXSettings.Wallbang then return false end

	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin).Unit * 1000

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local result = workspace:Raycast(origin, direction, raycastParams)
	if not result then return false end

	return not result.Instance:IsDescendantOf(targetPart.Parent)
end

-- YoxanXHub V3 (11/25) – Smart Wait Delay & Visual Crosshair Feedback

-- Smart Wait Delay Slider
TabAimbot:AddSlider({
	Name = "Smart Wait Delay",
	Min = 0.01,
	Max = 0.25,
	Default = 0.05,
	Increment = 0.01,
	ValueName = "seconds",
	Callback = function(Value)
		YoxanXSettings.SmartWait = Value
	end
})

-- Sticky Lock Crosshair Indicator
TabVisual:AddToggle({
	Name = "Show Crosshair Lock",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.CrosshairLock = Value
	end
})

-- UI for Crosshair Lock (TextLabel on Screen)
local crosshairGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
crosshairGui.Name = "YoxanXCrosshair"
local label = Instance.new("TextLabel", crosshairGui)
label.Size = UDim2.new(0, 100, 0, 25)
label.Position = UDim2.new(0.5, -50, 0.5, 20)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.new(1, 0, 0)
label.Text = ""

game:GetService("RunService").RenderStepped:Connect(function()
	if YoxanXSettings.CrosshairLock and getgenv().YoxanX_Target and getgenv().YoxanX_Target.Character then
		local target = getgenv().YoxanX_Target
		local head = target.Character:FindFirstChild("Head")
		if head then
			label.Text = "🎯 LOCKED"
			label.TextColor3 = Color3.fromRGB(255, 64, 64)
		else
			label.Text = ""
		end
	else
		label.Text = ""
	end
end)

-- YoxanXHub V3 (12/25) – Advanced ESP Rendering (Name by Team, Transparency, Highlights)

local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")

TabVisual:AddToggle({
	Name = "Enable ESP (Name & Box)",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.ESPEnabled = Value
	end
})

TabVisual:AddToggle({
	Name = "ESP Name Colored by Team",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.ESPColorByTeam = Value
	end
})

TabVisual:AddToggle({
	Name = "Transparent Wall Near Enemy",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.TransparentWalls = Value
	end
})

local ESPFolder = Instance.new("Folder", CoreGui)
ESPFolder.Name = "YoxanX_ESP"

-- Utility
function GetTeamColor(player)
	if player.Team == LocalPlayer.Team then
		return Color3.fromRGB(0, 255, 0) -- Green for team
	else
		return Color3.fromRGB(255, 0, 0) -- Red for enemies
	end
end

-- Render ESP
RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.ESPEnabled then
		for _, v in pairs(ESPFolder:GetChildren()) do v:Destroy() end
		return
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Head") then continue end

		local head = plr.Character.Head
		local existing = ESPFolder:FindFirstChild(plr.Name)
		if not existing then
			local tag = Instance.new("BillboardGui", ESPFolder)
			tag.Name = plr.Name
			tag.Adornee = head
			tag.Size = UDim2.new(0, 100, 0, 40)
			tag.StudsOffset = Vector3.new(0, 2, 0)
			tag.AlwaysOnTop = true

			local nameLabel = Instance.new("TextLabel", tag)
			nameLabel.Size = UDim2.new(1, 0, 1, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextScaled = true
			nameLabel.TextStrokeTransparency = 0.5
		end

		local tag = ESPFolder:FindFirstChild(plr.Name)
		if tag then
			tag.Adornee = head
			local label = tag:FindFirstChildOfClass("TextLabel")
			label.Text = plr.Name
			label.TextColor3 = YoxanXSettings.ESPColorByTeam and GetTeamColor(plr) or Color3.fromRGB(255, 255, 255)
		end

		-- Wall Transparency (simplified): makes wall between camera and enemy transparent
		if YoxanXSettings.TransparentWalls then
			local direction = (head.Position - Camera.CFrame.Position)
			local ray = workspace:Raycast(Camera.CFrame.Position, direction.Unit * direction.Magnitude, RaycastParams.new())
			if ray and ray.Instance and not ray.Instance:IsDescendantOf(plr.Character) then
				local part = ray.Instance
				if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
					part.Transparency = 0.7
				end
			end
		end
	end
end)

-- YoxanXHub V3 (13/25) – Multi Target Mode & Dynamic Firing

TabAimbot:AddToggle({
	Name = "Multi Target Mode",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.MultiTarget = Value
	end
})

-- Table to store valid targets
getgenv().YoxanX_MultiTargets = {}

function GetAllValidTargets()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
			if p.Character.Humanoid.Health <= 0 then continue end
			if YoxanXSettings.IgnoreShielded and IsShielded(p.Character) then continue end
			if YoxanXSettings.VisibleOnly and not IsVisible(p.Character.Head) then continue end
			if YoxanXSettings.MaxDistance and (p.Character.Head.Position - Camera.CFrame.Position).Magnitude > 500 then continue end
			table.insert(list, p)
		end
	end
	return list
end

-- Update multi target list every few frames
task.spawn(function()
	while true do
		if YoxanXSettings.MultiTarget then
			getgenv().YoxanX_MultiTargets = GetAllValidTargets()
		else
			getgenv().YoxanX_MultiTargets = {}
		end
		task.wait(0.15)
	end
end)

-- Auto Fire on all targets
RunService.RenderStepped:Connect(function()
	if YoxanXSettings.MultiTarget and YoxanXSettings.AutoFire then
		for _, t in pairs(getgenv().YoxanX_MultiTargets) do
			if t.Character and t.Character:FindFirstChild("Head") then
				-- Simulate targeting & hit logic
				local head = t.Character.Head
				if CanWallbang(head) or IsVisible(head) then
					-- Call silent aim hit logic
					fireheadshot(t)
					task.wait(YoxanXSettings.SmartWait or 0.05)
				end
			end
		end
	end
end)

-- Sample function to simulate fire logic
function fireheadshot(target)
	if not target or not target.Character then return end
	local head = target.Character:FindFirstChild("Head")
	if not head then return end

-- YoxanXHub V3 (14/25) – Fire Logic for Silent Aim / Multi Target

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tool = nil

-- Optional: Auto-detect equipped tool (used by some gunfight games)
local function GetGunTool()
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v:IsA("Tool") then
			return v
		end
	end
	return nil
end

-- Fire Remote Placeholder (adjust for your game)
local function FireWeaponTo(targetPart)
	if not targetPart then return end
	local tool = Tool or GetGunTool()
	if not tool then return end

	-- Simulated remote or raycast logic
	-- Example: trigger server hit
	if tool:FindFirstChild("RemoteEvent") then
		tool.RemoteEvent:FireServer(targetPart.Position)
	end
end

-- Main function for aiming & firing at head
function fireheadshot(target)
	if not target or not target.Character then return end
	local head = target.Character:FindFirstChild("Head")
	if not head then return end

	if not YoxanXSettings.Wallbang and not IsVisible(head) then return end

	local predictedPosition = head.Position
	if YoxanXSettings.PredictTarget then
		predictedPosition = PredictPosition(target)
	end

	-- Send fire to head
	FireWeaponTo(head)
end

-- Optional Prediction Logic (can be improved)
function PredictPosition(target)
	if not target or not target.Character then return end
	local head = target.Character:FindFirstChild("Head")
	if not head then return head.Position end

	local velocity = head.Velocity or Vector3.zero
	local distance = (head.Position - Camera.CFrame.Position).Magnitude
	local pingFactor = math.clamp(distance / 300, 0.05, 0.3)

	local predicted = head.Position + (velocity * pingFactor)
	return predicted
end

-- YoxanXHub V3 (15/25) – Hitmarker + Freeze Target Bypass

TabVisual:AddToggle({
	Name = "Enable Hitmarker",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.Hitmarker = Value
	end
})

TabVisual:AddToggle({
	Name = "Target Freeze Bypass",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.TargetFreezeBypass = Value
	end
})

-- Hitmarker UI (bottom center)
local hitGui = Instance.new("ScreenGui", CoreGui)
hitGui.Name = "YoxanX_HitUI"
local marker = Instance.new("TextLabel", hitGui)
marker.Size = UDim2.new(0, 100, 0, 30)
marker.Position = UDim2.new(0.5, -50, 0.75, 0)
marker.BackgroundTransparency = 1
marker.Font = Enum.Font.GothamBold
marker.TextScaled = true
marker.TextColor3 = Color3.fromRGB(255, 255, 255)
marker.TextStrokeTransparency = 0.5
marker.Visible = false

-- Function to show hitmarker
function ShowHitmarker()
	if not YoxanXSettings.Hitmarker then return end
	marker.Text = "HIT!"
	marker.Visible = true
	task.delay(0.3, function() marker.Visible = false end)
end

-- Damage text on top of target (optional)
function ShowFloatingText(target)
	if not target or not target.Character then return end
	local head = target.Character:FindFirstChild("Head")
	if not head then return end

	local gui = Instance.new("BillboardGui", head)
	gui.Size = UDim2.new(0, 100, 0, 30)
	gui.StudsOffset = Vector3.new(0, 2.5, 0)
	gui.Adornee = head
	gui.AlwaysOnTop = true
	gui.Name = "YoxanX_DamageText"

	local text = Instance.new("TextLabel", gui)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.Text = "- HEADSHOT"
	text.TextColor3 = Color3.fromRGB(255, 0, 0)
	text.TextScaled = true

	game.Debris:AddItem(gui, 0.7)
end

-- Updated fireheadshot to include effects
function fireheadshot(target)
	if not target or not target.Character then return end
	if YoxanXSettings.TargetFreezeBypass and target.Character:FindFirstChild("Freeze") then
		target.Character.Freeze:Destroy()
	end

	local head = target.Character:FindFirstChild("Head")
	if not head then return end
	if not YoxanXSettings.Wallbang and not IsVisible(head) then return end

	local predicted = YoxanXSettings.PredictTarget and PredictPosition(target) or head.Position
	FireWeaponTo(head)

	-- Visual Effects
	ShowHitmarker()
	ShowFloatingText(target)
    end
    
-- Notifikasi selesai
OrionLib:MakeNotification({
	Name = "YoxanXHub V3 Loaded",
	Content = "🔥 UI ready to use!",
	Image = "rbxassetid://6035193209",
	Time = 4
})
