-- YoxanXHub | Hypershot Gunfight - Silent Aim V2 (Part 1/5)
-- UI Base (OrionLib Original)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub V2 | Hypershot Gunfight",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "YoxanX_SilentAim"
})

getgenv().YoxanXSettings = {
	Enabled = false,
	ShowFOV = true,
	FOV = 150,
	TargetPart = "Head",
	TeamCheck = false,
	PredictMovement = true,
	HitChance = 100
}

-- Main Tab
local Tab = Window:MakeTab({
	Name = "Silent Aim",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddToggle({
	Name = "Enable Silent Aim",
	Default = false,
	Callback = function(state)
		getgenv().YoxanXSettings.Enabled = state
	end
})

Tab:AddToggle({
	Name = "Show FOV Circle",
	Default = true,
	Callback = function(val)
		getgenv().YoxanXSettings.ShowFOV = val
	end
})

Tab:AddSlider({
	Name = "FOV Radius",
	Min = 50,
	Max = 500,
	Default = 150,
	Increment = 5,
	ValueName = " px",
	Callback = function(val)
		getgenv().YoxanXSettings.FOV = val
	end
})

Tab:AddDropdown({
	Name = "Target Part",
	Default = "Head",
	Options = {"Head", "HumanoidRootPart", "UpperTorso"},
	Callback = function(part)
		getgenv().YoxanXSettings.TargetPart = part
	end
})

Tab:AddToggle({
	Name = "Team Check",
	Default = false,
	Callback = function(val)
		getgenv().YoxanXSettings.TeamCheck = val
	end
})

Tab:AddSlider({
	Name = "Hit Chance (%)",
	Min = 10,
	Max = 100,
	Default = 100,
	Increment = 5,
	ValueName = "%",
	Callback = function(val)
		getgenv().YoxanXSettings.HitChance = val
	end
})

Tab:AddToggle({
	Name = "Predict Movement",
	Default = true,
	Callback = function(val)
		getgenv().YoxanXSettings.PredictMovement = val
	end
})

-- Part 2/5 - Target Logic + Raycast Override (__namecall)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local function GetClosestTarget()
	local closest = nil
	local shortest = math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(getgenv().YoxanXSettings.TargetPart) then
			if getgenv().YoxanXSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
			local part = p.Character[getgenv().YoxanXSettings.TargetPart]
			local pos, visible = Camera:WorldToViewportPoint(part.Position)
			if visible then
				local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
				if distance < getgenv().YoxanXSettings.FOV and distance < shortest then
					shortest = distance
					closest = p
				end
			end
		end
	end
	return closest
end

local function CalculateDirection(target)
	local part = target.Character[getgenv().YoxanXSettings.TargetPart]
	local targetPos = part.Position
	if getgenv().YoxanXSettings.PredictMovement and target.Character:FindFirstChild("HumanoidRootPart") then
		local velocity = target.Character.HumanoidRootPart.Velocity
		targetPos = targetPos + (velocity * 0.125)
	end
	return (targetPos - Camera.CFrame.Position).Unit * 1000
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local args = {...}
	local method = getnamecallmethod()
	if getgenv().YoxanXSettings.Enabled and method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
		if math.random(0, 100) <= getgenv().YoxanXSettings.HitChance then
			local target = GetClosestTarget()
			if target and target.Character and target.Character:FindFirstChild(getgenv().YoxanXSettings.TargetPart) then
				local origin = Camera.CFrame.Position
				local direction = CalculateDirection(target)
				return oldNamecall(self, Ray.new(origin, direction), unpack(args, 2))
			end
		end
	end
	return oldNamecall(self, ...)
end)

-- Part 3/5: FOV Circle + Debug Tracker (FPS + Target)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV Circle
local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(0, 255, 255)
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 0.6
circle.Radius = getgenv().YoxanXSettings.FOV
circle.Visible = getgenv().YoxanXSettings.ShowFOV
circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Debug Text
local debugText = Drawing.new("Text")
debugText.Size = 15
debugText.Position = Vector2.new(15, Camera.ViewportSize.Y - 60)
debugText.Color = Color3.fromRGB(255, 255, 255)
debugText.Outline = true
debugText.Center = false
debugText.Visible = true

-- FPS Counter
local lastTime = tick()
local fps = 60

RunService.RenderStepped:Connect(function()
	local t = tick()
	local dt = t - lastTime
	lastTime = t
	fps = math.floor(1 / dt)

	-- Update FOV visual
	circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	circle.Radius = getgenv().YoxanXSettings.FOV
	circle.Visible = getgenv().YoxanXSettings.ShowFOV

	-- Get locked target
	local targetName = "None"
	local function GetClosestTarget()
		local closest, shortest = nil, math.huge
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(getgenv().YoxanXSettings.TargetPart) then
				if getgenv().YoxanXSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
				local pos, visible = Camera:WorldToViewportPoint(p.Character[getgenv().YoxanXSettings.TargetPart].Position)
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
				if visible and dist < getgenv().YoxanXSettings.FOV and dist < shortest then
					shortest = dist
					closest = p
				end
			end
		end
		return closest
	end

	local lockTarget = GetClosestTarget()
	if lockTarget then
		targetName = lockTarget.Name
	end

	debugText.Text = "FPS: " .. tostring(fps) .. "\nTarget: " .. targetName
end)

-- Part 4/5: Gun Mod (No Recoil, No Spread, Auto Fire)
local function ApplyGunMods()
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "Recoil") and rawget(v, "Spread") then
            -- Remove recoil
            if type(v.Recoil) == "table" then
                for i in pairs(v.Recoil) do
                    v.Recoil[i] = 0
                end
            elseif type(v.Recoil) == "number" then
                v.Recoil = 0
            end

            -- Remove spread
            if type(v.Spread) == "table" then
                for i in pairs(v.Spread) do
                    v.Spread[i] = 0
                end
            elseif type(v.Spread) == "number" then
                v.Spread = 0
            end

            -- Fire rate boost (optional)
            if v.FireRate and type(v.FireRate) == "number" then
                v.FireRate = math.max(0.05, v.FireRate * 0.5)
            end

            -- Auto mode
            if v.Auto ~= nil then
                v.Auto = true
            end
        end
    end
end

-- Apply on spawn
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    ApplyGunMods()
end)

-- Apply manually if already spawned
if LocalPlayer.Character then
    ApplyGunMods()
end

-- Part 5/5: ESP + Debug Info + Kill Notifier
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Drawing: target tracer
local box = Drawing.new("Square")
box.Color = Color3.fromRGB(255, 0, 0)
box.Thickness = 1
box.Filled = false
box.Transparency = 0.9
box.Size = Vector2.new(50, 50)
box.Visible = false

-- Drawing: debug stats
local stats = Drawing.new("Text")
stats.Size = 14
stats.Color = Color3.fromRGB(200, 255, 200)
stats.Position = Vector2.new(10, 10)
stats.Outline = true
stats.Visible = true
stats.Text = "Debug info"

-- Helper to get closest target (reused)
local function GetClosestTarget()
	local closest, shortest = nil, math.huge
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(getgenv().YoxanXSettings.TargetPart) then
			if getgenv().YoxanXSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
			local pos, visible = Camera:WorldToViewportPoint(p.Character[getgenv().YoxanXSettings.TargetPart].Position)
			local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
			if visible and dist < getgenv().YoxanXSettings.FOV and dist < shortest then
				shortest = dist
				closest = p
			end
		end
	end
	return closest
end

-- Ping tracker
local function GetPing()
	local success, ping = pcall(function()
		return tonumber(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1])
	end)
	return success and ping or 0
end

-- Kill notifier
local function NotifyKill(target)
	if target and target:FindFirstChild("Humanoid") then
		target.Humanoid.Died:Connect(function()
			print("[YoxanXHub] Eliminated: " .. target.Name)
		end)
	end
end

-- Main ESP + Debug Loop
RunService.RenderStepped:Connect(function()
	local t = GetClosestTarget()
	if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = t.Character.HumanoidRootPart
		local screenPos, visible = Camera:WorldToViewportPoint(hrp.Position)
		if visible then
			box.Position = Vector2.new(screenPos.X - 25, screenPos.Y - 25)
			box.Visible = true
			NotifyKill(t.Character)
		else
			box.Visible = false
		end
		stats.Text = "[YoxanXHub Debug]\nTarget: " .. t.Name ..
			"\nFOV: " .. tostring(getgenv().YoxanXSettings.FOV) ..
			"\nHitChance: " .. tostring(getgenv().YoxanXSettings.HitChance) ..
			"\nPing: " .. tostring(GetPing())
	else
		box.Visible = false
		stats.Text = "[YoxanX Debug]\nTarget: None\nPing: " .. tostring(GetPing())
	end
end)
