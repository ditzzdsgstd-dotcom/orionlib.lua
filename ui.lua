-- YoxanXHub | Hypershot Gunfight V2.5 (1/25)
-- Setup OrionLib UI + Tabs + Default Settings

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ditzzdsgstd-dotcom/orionlib.lua/main/orionlib.lua"))()

local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub V2.5 | Hypershot Gunfight",
	HidePremium = false,
	IntroEnabled = true,
	IntroText = "YoxanXHub V2.5 Loading...",
	SaveConfig = false,
	ConfigFolder = "YoxanXConfig"
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

-- YoxanXHub | Hypershot Gunfight V2.5 (2/25)
-- Main Tab UI Toggles

Tab_Main:AddToggle({
	Name = "Silent Aim",
	Default = true,
	Callback = function(state)
		YoxanXSettings.SilentAim = state
	end
})

Tab_Main:AddToggle({
	Name = "100% Headshot Lock",
	Default = true,
	Callback = function(state)
		YoxanXSettings.HeadshotOnly = state
	end
})

Tab_Main:AddToggle({
	Name = "ESP Enabled",
	Default = true,
	Callback = function(state)
		YoxanXSettings.ESPEnabled = state
	end
})

Tab_Main:AddToggle({
	Name = "Sticky Lock Target",
	Default = true,
	Callback = function(state)
		YoxanXSettings.StickyLock = state
	end
})

Tab_Main:AddToggle({
	Name = "Visible Only Target",
	Default = true,
	Callback = function(state)
		YoxanXSettings.VisibleOnly = state
	end
})

Tab_Main:AddToggle({
	Name = "Multi Target Mode",
	Default = true,
	Callback = function(state)
		YoxanXSettings.MultiTarget = state
	end
})

Tab_Main:AddToggle({
	Name = "Wallbang Mode",
	Default = true,
	Callback = function(state)
		YoxanXSettings.Wallbang = state
	end
})

Tab_Main:AddSlider({
	Name = "Smart Wait Delay",
	Min = 0.01,
	Max = 0.2,
	Default = 0.05,
	Increment = 0.01,
	ValueName = "s",
	Callback = function(val)
		YoxanXSettings.SmartWait = val
	end
})

-- YoxanXHub | Hypershot Gunfight V2.5 (3/25)
-- ESP Full Logic: Team Color, Name, Highlight, Wall Transparency (3D WallCheck)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function GetTeamColor(player)
	if not player.Team then return Color3.fromRGB(255, 255, 255) end
	if player.Team == LocalPlayer.Team then
		return Color3.fromRGB(0, 255, 0) -- Green (ally)
	else
		return Color3.fromRGB(255, 0, 0) -- Red (enemy)
	end
end

local function ApplyESP(player)
	if player.Character and not player.Character:FindFirstChild("YoxESP") then
		local highlight = Instance.new("Highlight")
		highlight.Name = "YoxESP"
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0
		highlight.OutlineColor = GetTeamColor(player)
		highlight.Adornee = player.Character
		highlight.Parent = player.Character
	end
end

-- ESP update loop
RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.ESPEnabled then return end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			ApplyESP(p)
		end
	end
end)

-- Wall transparency (enemy through wall glow)
RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.ESPEnabled then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local root = plr.Character.HumanoidRootPart
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist
			rayParams.FilterDescendantsInstances = {LocalPlayer.Character, plr.Character}
			local result = Workspace:Raycast(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
			if result and not result.Instance:IsDescendantOf(plr.Character) then
				local highlight = plr.Character:FindFirstChild("YoxESP")
				if highlight then
					highlight.OutlineColor = Color3.fromRGB(255, 255, 0) -- yellow glow if behind wall
				end
			else
				local highlight = plr.Character:FindFirstChild("YoxESP")
				if highlight then
					highlight.OutlineColor = GetTeamColor(plr)
				end
			end
		end
	end
end)

OrionLib:MakeNotification({
	Name = "YoxanXHub V2.5 Loaded",
	Content = "Ready to use.",
	Image = "rbxassetid://6035185487",
	Time = 4
})
