-- YoxanXHub | Hypershot Gunfight V2.5 (1/30)
-- Load OrionLib & Setup UI

-- Load OrionLib from GitHub
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ditzzdsgstd-dotcom/orionlib.lua/main/orionlib.lua"))()

-- Init main window
local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub V2.5 | Hypershot Gunfight",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "YoxanXHub V2.5 Loaded",
    ConfigFolder = "YoxanXHubV2_5"
})

-- Tabs
local Tab_Main = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Tab_Visual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://6031075938", PremiumOnly = false})
local Tab_Safety = Window:MakeTab({Name = "Safety", Icon = "rbxassetid://6035047377", PremiumOnly = false})
local Tab_Debug = Window:MakeTab({Name = "Debug", Icon = "rbxassetid://6031071050", PremiumOnly = false})

-- Global Settings
getgenv().YoxanXSettings = {
    Enabled = false,
    SilentAim = false,
    HeadshotOnly = false,
    ESPEnabled = false,
    StickyLock = false,
    VisibleOnly = true,
    MaxDistance = true,
    MultiTarget = false,
    WallCheck3D = true,
    SmartWait = 0.05,
    DebugMode = false,
    IgnoreShielded = true,
    AutoFire = true,
    Wallbang = true,
    TeamColorESP = true,
    AntiOverkill = true,
    PingBasedPrediction = true,
    BypassInvisible = true,
    TargetFreezeBypass = true,
    ShowHitmarker = true,
    HitEffect = "Flash",
    UIReady = true
}

-- Notification
OrionLib:MakeNotification({
	Name = "YoxanXHub V2.5 Loaded",
	Content = "Ready to Use.",
	Image = "rbxassetid://4483345998",
	Time = 5
})

-- YoxanXHub V2.5 | Main Tab UI (2/30)

Tab_Main:AddToggle({
	Name = "Silent Aim",
	Default = false,
	Callback = function(value)
		YoxanXSettings.SilentAim = value
	end
})

Tab_Main:AddToggle({
	Name = "100% Headshot",
	Default = false,
	Callback = function(value)
		YoxanXSettings.HeadshotOnly = value
	end
})

Tab_Main:AddToggle({
	Name = "ESP (Show Enemies)",
	Default = false,
	Callback = function(value)
		YoxanXSettings.ESPEnabled = value
	end
})

Tab_Main:AddToggle({
	Name = "Sticky Lock-On",
	Default = false,
	Callback = function(value)
		YoxanXSettings.StickyLock = value
	end
})

Tab_Main:AddToggle({
	Name = "Visible Only Target",
	Default = true,
	Callback = function(value)
		YoxanXSettings.VisibleOnly = value
	end
})

Tab_Main:AddToggle({
	Name = "Multi Target Mode",
	Default = false,
	Callback = function(value)
		YoxanXSettings.MultiTarget = value
	end
})

Tab_Main:AddSlider({
	Name = "Smart Wait Delay",
	Min = 0.01,
	Max = 0.2,
	Default = 0.05,
	Increment = 0.01,
	ValueName = "seconds",
	Callback = function(value)
		YoxanXSettings.SmartWait = value
	end
})

-- YoxanXHub V2.5 | ESP, Wallcheck, Auto Swap Logic (3/30)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function GetTeamColor(player)
	if not player or not player.Team then return Color3.new(1, 1, 1) end
	if player.Team == LocalPlayer.Team then
		return Color3.fromRGB(0, 255, 0) -- Green for teammates
	else
		return Color3.fromRGB(255, 0, 0) -- Red for enemies
	end
end

-- ESP handler
local function CreateESP(target)
	if not target.Character or not target.Character:FindFirstChild("Head") then return end
	if target:FindFirstChild("YoxESP") then return end

	local box = Instance.new("BillboardGui")
	box.Name = "YoxESP"
	box.Adornee = target.Character.Head
	box.Size = UDim2.new(4, 0, 4, 0)
	box.AlwaysOnTop = true
	box.StudsOffset = Vector3.new(0, 1.5, 0)

	local label = Instance.new("TextLabel", box)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = GetTeamColor(target)
	label.Text = target.Name
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold

	box.Parent = target.Character

	task.delay(10, function()
		if box and box.Parent then box:Destroy() end
	end)
end

-- ESP update loop
RunService.RenderStepped:Connect(function()
	if not YoxanXSettings.ESPEnabled then return end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and not plr.Character:FindFirstChild("YoxESP") then
			CreateESP(plr)
		end
	end
end)

-- Auto switch target when enemy dies
RunService.Heartbeat:Connect(function()
	if not YoxanXSettings.AntiOverkill then return end
	if getgenv().YoxanX_Target and getgenv().YoxanX_Target.Character then
		local humanoid = getgenv().YoxanX_Target.Character:FindFirstChild("Humanoid")
		if humanoid and humanoid.Health <= 0 then
			getgenv().YoxanX_Target = nil
		end
	end
end)
