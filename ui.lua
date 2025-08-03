-- YoxanXHub | Hypershot Gunfight V2.5+ (1/25 - Core Init & Window)

repeat wait() until game:IsLoaded()
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
end)
if not success then
    return warn("⚠️ Failed to load OrionLib. Please check your connection.")
end

local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub V2.5 | Hypershot Gunfight",
	HidePremium = false,
	IntroEnabled = true,
	IntroText = "YoxanXHub V2.5 Loading...",
	SaveConfig = true,
	ConfigFolder = "YoxanXHub"
})

-- Tabs
local Tab_Main = Window:MakeTab({Name = "Main", Icon = "rbxassetid://6035185487", PremiumOnly = false})
local Tab_Visual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://6031265976", PremiumOnly = false})
local Tab_Safety = Window:MakeTab({Name = "Safety", Icon = "rbxassetid://6035192843", PremiumOnly = false})
local Tab_Debug = Window:MakeTab({Name = "Debug", Icon = "rbxassetid://6035047377", PremiumOnly = false})

-- Global Settings
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
	PingPrediction = true
}


-- UI Loaded Notif
OrionLib:MakeNotification({
	Name = "YoxanXHub V2.5 Loaded",
	Content = "Ready to use.",
	Image = "rbxassetid://6035185487",
	Time = 4
})

-- YoxanXHub | Hypershot Gunfight V2.5+ (2/25)
-- Toggle UI: Silent Aim, Headshot Lock, ESP, Smart Wait, Multi Target, etc.

local OrionLib = OrionLib -- ambil dari 1/25
local Tab = Tab_Main

-- Silent Aim Toggle
Tab:AddToggle({
	Name = "Silent Aim",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.SilentAim = Value
	end
})

-- Headshot Only
Tab:AddToggle({
	Name = "Headshot Only",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.HeadshotOnly = Value
	end
})

-- ESP Toggle
Tab_Visual:AddToggle({
	Name = "Enable ESP",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.ESPEnabled = Value
	end
})

-- Smart Wait (Slider 0.01 - 0.1)
Tab:AddSlider({
	Name = "Smart Wait Delay",
	Min = 0.01,
	Max = 0.1,
	Default = 0.05,
	Increment = 0.01,
	ValueName = "s",
	Callback = function(Value)
		YoxanXSettings.SmartWait = Value
	end
})

-- Multi Target Mode
Tab:AddToggle({
	Name = "Multi Target Mode",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.MultiTarget = Value
	end
})

-- Visible Only
Tab:AddToggle({
	Name = "Visible Only Targets",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.VisibleOnly = Value
	end
})

-- Max Distance Lock
Tab:AddToggle({
	Name = "Max Distance Limit (500 studs)",
	Default = true,
	Callback = function(Value)
		YoxanXSettings.MaxDistance = Value
	end
})

-- YoxanXHub | Hypershot Gunfight V2.5+ (3/25)
-- Targeting Logic: Head Priority, Prediction, Sticky Lock, etc.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Utility: Visibility Check
local function IsVisible(part)
	if not part then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
	return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

-- Utility: Prediction
local function PredictPosition(part, velocity, delay)
	return part.Position + (velocity * delay)
end

-- Target Finder
local function GetClosestTarget()
	local closest = nil
	local shortest = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
			local char = player.Character
			local head = char:FindFirstChild("Head")
			local human = char:FindFirstChild("Humanoid")

			if human and human.Health > 0 then
				if YoxanXSettings.IgnoreShielded and (char:FindFirstChild("ForceField") or char:FindFirstChild("Shield")) then continue end
				if YoxanXSettings.VisibleOnly and not IsVisible(head) then continue end

				local distance = (head.Position - Camera.CFrame.Position).Magnitude
				if YoxanXSettings.MaxDistance and distance > 500 then continue end

				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
					local pos2D = Vector2.new(screenPos.X, screenPos.Y)
					local mag = (pos2D - center).Magnitude
					if mag < shortest then
						shortest = mag
						closest = player
					end
				end
			end
		end
	end

	return closest
end

-- Lock-On Logic
getgenv().YoxanX_Target = nil

RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.SilentAim then return end

	local current = getgenv().YoxanX_Target

	if not current or not current.Character or not current.Character:FindFirstChild("Head") then
		getgenv().YoxanX_Target = GetClosestTarget()
	elseif YoxanXSettings.StickyLock then
		local char = current.Character
		if not char or not char:FindFirstChild("Humanoid") or char:FindFirstChild("Humanoid").Health <= 0 then
			getgenv().YoxanX_Target = nil
		end
	else
		getgenv().YoxanX_Target = nil
	end
end)
