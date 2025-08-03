local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub | Hypershot Gunfight V2",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "YoxanXHub V2",
    ConfigFolder = "YoxanX"
})

OrionLib:MakeNotification({
    Name = "YoxanXHub V2 Loaded",
    Content = "Ready to use.",
    Image = "rbxassetid://4483345998",
    Time = 4
})

-- Tabs
local AimbotTab = Window:MakeTab({ Name = "Aimbot", Icon = "rbxassetid://4370345148", PremiumOnly = false })
local ESPTab = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://6031075931", PremiumOnly = false })
local SafetyTab = Window:MakeTab({ Name = "Safety", Icon = "rbxassetid://6034996695", PremiumOnly = false })

-- Settings Table
getgenv().YoxanXSettings = {
    Enabled = true,
    SilentAim = true,
    ESP = true,
    StickyLock = true,
    WallCheck = true,
    SmartWait = 0.05,
    FakeInput = false,
    TransparentWalls = true,
}

-- Aimbot Tab
AimbotTab:AddToggle({
    Name = "Silent Aim",
    Default = true,
    Callback = function(v) YoxanXSettings.SilentAim = v end
})

AimbotTab:AddToggle({
    Name = "Sticky Lock-On",
    Default = true,
    Callback = function(v) YoxanXSettings.StickyLock = v end
})

AimbotTab:AddToggle({
    Name = "WallCheck (3D)",
    Default = true,
    Callback = function(v) YoxanXSettings.WallCheck = v end
})

-- ESP Tab
ESPTab:AddToggle({
    Name = "ESP (Show Enemies)",
    Default = true,
    Callback = function(v) YoxanXSettings.ESP = v end
})

ESPTab:AddToggle({
    Name = "Transparent Wall ESP",
    Default = true,
    Callback = function(v) YoxanXSettings.TransparentWalls = v end
})

-- Safety Tab
SafetyTab:AddSlider({
    Name = "Smart Wait Delay",
    Min = 0.01,
    Max = 0.2,
    Default = 0.05,
    Increment = 0.01,
    ValueName = "seconds",
    Callback = function(v) YoxanXSettings.SmartWait = v end
})

SafetyTab:AddToggle({
    Name = "Fake Input Simulation",
    Default = false,
    Callback = function(v) YoxanXSettings.FakeInput = v end
})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function makeESPBox(part, color)
	local box = Instance.new("BoxHandleAdornment")
	box.Adornee = part
	box.AlwaysOnTop = true
	box.ZIndex = 10
	box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
	box.Transparency = 0.5
	box.Color3 = color
	box.Name = "YoxanX_ESP"
	box.Parent = part
	return box
end

local function isVisible(head)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, workspace.Ignore}
	local result = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
	return result and result.Instance and result.Instance:IsDescendantOf(head.Parent)
end

local function makeWallTransparent(hit)
	if hit and hit:IsA("BasePart") and not hit:IsDescendantOf(LocalPlayer.Character) then
		hit.LocalTransparencyModifier = 0.3
	end
end

local function clearESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then
			for _, part in pairs(p.Character:GetDescendants()) do
				if part:IsA("BasePart") and part:FindFirstChild("YoxanX_ESP") then
					part.YoxanX_ESP:Destroy()
				end
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.ESP then return end

	clearESP()

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local part = player.Character:FindFirstChild("HumanoidRootPart")
			local head = player.Character:FindFirstChild("Head")
			if part and head then
				local teamColor = player.TeamColor.Color
				local color = (player.Team ~= LocalPlayer.Team) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0) -- red for enemy, green for ally
				makeESPBox(part, color)

				if getgenv().YoxanXSettings.TransparentWalls then
					local result = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000)
					if result and not result.Instance:IsDescendantOf(player.Character) then
						makeWallTransparent(result.Instance)
					end
				end
			end
		end
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Current locked target
getgenv().YoxanX_Target = nil

local function IsVisible(part)
	if not part then return false end
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
	local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
	return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function IsShielded(character)
	return character:FindFirstChild("ForceField") or character:FindFirstChild("Shield")
end

local function PredictPosition(target)
	local hrp = target:FindFirstChild("HumanoidRootPart")
	if not hrp then return hrp.Position end
	local velocity = hrp.Velocity
	local ping = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
	return hrp.Position + (velocity * ping)
end

local function GetClosestTarget()
	local closest = nil
	local minDist = math.huge

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local char = player.Character
			local head = char:FindFirstChild("Head")

			if getgenv().YoxanXSettings.VisibleOnly and not IsVisible(head) then continue end
			if getgenv().YoxanXSettings.IgnoreShielded and IsShielded(char) then continue end
			if getgenv().YoxanXSettings.MaxDistance and (head.Position - Camera.CFrame.Position).Magnitude > 500 then continue end

			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
				if dist < minDist then
					closest = player
					minDist = dist
				end
			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.Enabled then return end

	local current = getgenv().YoxanX_Target

	if not current or not current.Character or not current.Character:FindFirstChild("Head") then
		local newTarget = GetClosestTarget()
		if newTarget then
			getgenv().YoxanX_Target = newTarget
		end
	elseif getgenv().YoxanXSettings.StickyLock then
		if not current.Character or not current.Character:FindFirstChild("Head") then
			getgenv().YoxanX_Target = nil
		end
	else
		getgenv().YoxanX_Target = nil
	end
end)

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Get current target head
local function GetAimPart()
	local target = getgenv().YoxanX_Target
	if target and target.Character and target.Character:FindFirstChild("Head") then
		return target.Character.Head
	end
	return nil
end

-- Smart Wait Delay
local function WaitDelay()
	task.wait(getgenv().YoxanXSettings.SmartWait or 0.05)
end

-- Fake input simulation
local function SimulateClick()
	if getgenv().YoxanXSettings.FakeInput then
		mouse1press()
		task.wait(0.01)
		mouse1release()
	end
end

-- Anti Recoil (Camera Shake Reset)
local function AntiRecoil()
	Camera.CFrame = Camera.CFrame
end

-- Bullet Flash (Visual)
local function BulletFlash(from, to)
	local beam = Instance.new("Beam", workspace)
	local att1 = Instance.new("Attachment", workspace.Terrain)
	local att2 = Instance.new("Attachment", workspace.Terrain)
	att1.WorldPosition = from
	att2.WorldPosition = to
	beam.Attachment0 = att1
	beam.Attachment1 = att2
	beam.Color = ColorSequence.new(Color3.new(1, 1, 0))
	beam.Width0 = 0.1
	beam.Width1 = 0.05
	beam.LightEmission = 1
	beam.FaceCamera = true
	game:GetService("Debris"):AddItem(att1, 0.2)
	game:GetService("Debris"):AddItem(att2, 0.2)
	game:GetService("Debris"):AddItem(beam, 0.2)
end

-- Shoot logic (RenderStepped)
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.Enabled or not getgenv().YoxanXSettings.SilentAim then return end

	local head = GetAimPart()
	if head then
		local direction = (head.Position - Camera.CFrame.Position).Unit * 1000

		-- Bullet flash effect (optional visual)
		BulletFlash(Camera.CFrame.Position, head.Position)

		-- Simulated click or direct input
		SimulateClick()

		-- Anti recoil
		AntiRecoil()

		-- Wait for delay
		WaitDelay()
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local function CreateHitMarker()
	local gui = Instance.new("BillboardGui", LocalPlayer:WaitForChild("PlayerGui"))
	gui.Name = "YoxanX_Hitmarker"
	gui.Size = UDim2.new(0, 100, 0, 40)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = true

	local text = Instance.new("TextLabel", gui)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = "Hit!"
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true

	TweenService:Create(text, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	game:GetService("Debris"):AddItem(gui, 0.5)
end

-- Freeze bypass check (assume player is hittable if humanoid health > 0)
local function CanBeHit(player)
	local char = player.Character
	if not char then return false end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0
end

-- ESP Overlay Name + Hitmarker
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.ESP then return end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and CanBeHit(player) then
			local head = player.Character:FindFirstChild("Head")
			if head and not head:FindFirstChild("YoxanX_NameESP") then
				local billboard = Instance.new("BillboardGui", head)
				billboard.Name = "YoxanX_NameESP"
				billboard.Size = UDim2.new(0, 100, 0, 20)
				billboard.AlwaysOnTop = true
				billboard.StudsOffset = Vector3.new(0, 1.5, 0)

				local text = Instance.new("TextLabel", billboard)
				text.Size = UDim2.new(1, 0, 1, 0)
				text.BackgroundTransparency = 1
				text.Text = player.DisplayName or player.Name
				text.Font = Enum.Font.GothamBold
				text.TextScaled = true
				text.TextColor3 = (player.Team == LocalPlayer.Team) and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
			end
		end
	end
end)

-- Trigger Hitmarker when your bullet touches
local function ListenForHit()
	local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
	if not tool then return end
	for _, v in pairs(tool:GetDescendants()) do
		if v:IsA("TouchTransmitter") then
			v.Touched:Connect(function(hit)
				if hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid") then
					CreateHitMarker()
				end
			end)
		end
	end
end

ListenForHit()
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	ListenForHit()
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Auto filters
local function IsValidTarget(player)
	if not player.Character then return false end
	if player.Team == LocalPlayer.Team then return false end
	local hum = player.Character:FindFirstChildOfClass("Humanoid")
	local head = player.Character:FindFirstChild("Head")
	if not hum or not head then return false end
	if hum.Health <= 0 then return false end
	if (head.Position - Camera.CFrame.Position).Magnitude > 500 then return false end
	if player.Character:FindFirstChild("NPC") or player.Character:FindFirstChild("Bot") then return false end
	return true
end

-- Prioritize lowest HP if multiple valid targets
local function GetBestTarget()
	local best = nil
	local lowestHP = math.huge
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and IsValidTarget(plr) then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health < lowestHP then
				best = plr
				lowestHP = hum.Health
			end
		end
	end
	return best
end

-- Overkill prevention: if current target dies, switch
game:GetService("RunService").Heartbeat:Connect(function()
	if not getgenv().YoxanXSettings.Enabled then return end

	local target = getgenv().YoxanX_Target
	if target and (not IsValidTarget(target)) then
		local nextTarget = GetBestTarget()
		if nextTarget then
			getgenv().YoxanX_Target = nextTarget
		end
	end
end)

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wallbang logic: Raycast to enemy's head
local function CanWallbang(targetPart)
	if not targetPart then return false end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, workspace.Terrain}
	rayParams.IgnoreWater = true

	local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, rayParams)

	-- If it hits target part or something inside the character, allow wallbang
	return (not result) or (result.Instance and result.Instance:IsDescendantOf(targetPart.Parent))
end

-- Predicted head position for advanced movement
local function PredictHead(target)
	if not target or not target.Character then return nil end
	local head = target.Character:FindFirstChild("Head")
	local hrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not head or not hrp then return nil end

	local velocity = hrp.Velocity
	local ping = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
	local distance = (head.Position - Camera.CFrame.Position).Magnitude
	local bulletSpeed = 250 -- you can adjust this per gun

	local travelTime = distance / bulletSpeed
	local predictedPosition = head.Position + (velocity * (ping + travelTime))

	return predictedPosition
end

-- Smart check before shooting
local function ShouldShoot(target)
	if not target or not target.Character then return false end
	local head = target.Character:FindFirstChild("Head")
	if not head then return false end
	if getgenv().YoxanXSettings.WallCheck and not CanWallbang(head) then return false end
	return true
end

-- Attach to shoot system
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.Enabled or not getgenv().YoxanXSettings.SilentAim then return end
	local target = getgenv().YoxanX_Target
	if target and ShouldShoot(target) then
		local predicted = PredictHead(target)
		if predicted then
			-- Update head aim position globally
			getgenv().YoxanX_HeadAim = predicted
		end
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Crosshair Lock Indicator
local function CreateLockIcon()
	if not getgenv().YoxanX_Crosshair then
		local gui = Instance.new("ScreenGui", game.CoreGui)
		gui.Name = "YoxanX_Crosshair"

		local icon = Instance.new("TextLabel", gui)
		icon.Name = "TargetDot"
		icon.Size = UDim2.new(0, 20, 0, 20)
		icon.Position = UDim2.new(0.5, -10, 0.5, -10)
		icon.BackgroundTransparency = 1
		icon.Text = "📍"
		icon.TextColor3 = Color3.new(1, 0, 0)
		icon.TextScaled = true
		icon.Font = Enum.Font.GothamBold

		getgenv().YoxanX_Crosshair = icon
	end
end

-- Auto Remove Visuals (ESP or icons that overload)
local function CleanESP()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			for _, part in pairs(plr.Character:GetDescendants()) do
				if part:IsA("BillboardGui") or part:IsA("BoxHandleAdornment") then
					if part.Name == "YoxanX_NameESP" or part.Name == "YoxanX_ESP" then
						part:Destroy()
					end
				end
			end
		end
	end
end

-- Anti Part Shield (Forcefield Detectors)
local function IsPartShielded(char)
	for _, part in pairs(char:GetChildren()) do
		if part:IsA("ForceField") or (part:IsA("Part") and part.Name:lower():find("shield")) then
			return true
		end
	end
	return false
end

-- Crosshair Logic
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.Enabled then return end
	CleanESP()

	local target = getgenv().YoxanX_Target
	if getgenv().YoxanX_Crosshair then
		getgenv().YoxanX_Crosshair.Visible = target ~= nil
	end
end)

CreateLockIcon()

local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- FPS & Ping Debug UI
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "YoxanX_Debug"

local infoLabel = Instance.new("TextLabel", screenGui)
infoLabel.Size = UDim2.new(0, 220, 0, 60)
infoLabel.Position = UDim2.new(1, -230, 0, 10)
infoLabel.BackgroundTransparency = 0.3
infoLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
infoLabel.TextColor3 = Color3.new(1, 1, 1)
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 14
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Ping & FPS Logic
local lastTime = tick()
local frames = 0
local fps = 0

RunService.RenderStepped:Connect(function()
	frames = frames + 1
	if tick() - lastTime >= 1 then
		fps = frames
		frames = 0
		lastTime = tick()
	end

	local pingStat = Stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem"):FindFirstChild("Data Ping")
	local ping = pingStat and math.floor(pingStat:GetValue()) or 0

	infoLabel.Text = "YoxanXHub V2\nFPS: " .. tostring(fps) .. "\nPing: " .. tostring(ping) .. " ms"

	-- Adjust hit chance if ping is high
	if getgenv().YoxanXSettings.AutoPingAdjust then
		if ping >= 200 then
			getgenv().YoxanXSettings.SmartWait = 0.09
		elseif ping >= 100 then
			getgenv().YoxanXSettings.SmartWait = 0.06
		else
			getgenv().YoxanXSettings.SmartWait = 0.04
		end
	end
end)

-- Toggle Status Cleanup
if getgenv().YoxanXSettings == nil then
	getgenv().YoxanXSettings = {
		Enabled = true,
		SilentAim = true,
		ESP = true,
		StickyLock = true,
		WallCheck = true,
		VisibleOnly = true,
		IgnoreShielded = true,
		MaxDistance = true,
		SmartWait = 0.05,
		FakeInput = true,
		AutoPingAdjust = true
	}
end

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = game:GetService("Players").LocalPlayer

-- Transparent wall ESP effect
local function SetTransparency(part, value)
	if part:IsA("BasePart") and part.Transparency < 0.8 then
		local tween = TweenService:Create(part, TweenInfo.new(0.3), {Transparency = value})
		tween:Play()
	end
end

local function ResetTransparency(part)
	if part:IsA("BasePart") and part.Transparency ~= 0 then
		local tween = TweenService:Create(part, TweenInfo.new(0.3), {Transparency = 0})
		tween:Play()
	end
end

local function MakeWallTransparentBetween(target)
	local origin = Camera.CFrame.Position
	local head = target.Character and target.Character:FindFirstChild("Head")
	if not head then return end

	local direction = (head.Position - origin).Unit * 500
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, target.Character}

	local ray = Workspace:Raycast(origin, direction, rayParams)
	if ray and ray.Instance and not ray.Instance:IsDescendantOf(target.Character) then
		SetTransparency(ray.Instance, 0.5)
		delay(1.5, function() ResetTransparency(ray.Instance) end)
	end
end

RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.ESP then return end
	local tgt = getgenv().YoxanX_Target
	if tgt and tgt.Character then
		MakeWallTransparentBetween(tgt)
	end
end)

-- Fallback Aim if head missing
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.Enabled then return end
	local tgt = getgenv().YoxanX_Target
	if tgt and tgt.Character then
		local head = tgt.Character:FindFirstChild("Head") or tgt.Character:FindFirstChild("UpperTorso") or tgt.Character:FindFirstChild("HumanoidRootPart")
		if head then
			getgenv().YoxanX_HeadAim = head.Position
		end
	end
end)

-- Final Notification
local OrionLib = getgenv().OrionLib
if OrionLib then
	OrionLib:MakeNotification({
		Name = "YoxanXHub V2 Loaded",
		Content = "Ready to use.",
		Image = "rbxassetid://7733960981",
		Time = 5
	})
end

-- Runtime Protection & Auto Reset
if not getgenv().YoxanXHubLoaded then
	getgenv().YoxanXHubLoaded = true
	getgenv().YoxanXSettings = getgenv().YoxanXSettings or {}
	local default = {
		Enabled = true,
		SilentAim = true,
		StickyLock = true,
		ESP = true,
		WallCheck = true,
		VisibleOnly = true,
		IgnoreShielded = true,
		MaxDistance = true,
		SmartWait = 0.05,
		AutoPingAdjust = true,
		FakeInput = true,
		HitMarker = true,
		ShowLockIcon = true
	}
	for k, v in pairs(default) do
		if getgenv().YoxanXSettings[k] == nil then
			getgenv().YoxanXSettings[k] = v
		end
	end
else
	warn("YoxanXHub already loaded, skipping duplicate load")
	return
end

-- Toggle Status Debug Print (Optional)
local function PrintToggles()
	print("==== YoxanXHub V2 Toggles ====")
	for k, v in pairs(getgenv().YoxanXSettings) do
		print(k .. ": " .. tostring(v))
	end
end

-- Cleanup Old UIs
local function CleanupUI()
	for _, ui in pairs(game:GetService("CoreGui"):GetChildren()) do
		if ui.Name == "YoxanX_Crosshair" or ui.Name == "YoxanX_Debug" then
			ui:Destroy()
		end
	end
end

-- Reset ESP (if relaunch)
for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
	if plr.Character then
		for _, gui in pairs(plr.Character:GetDescendants()) do
			if gui:IsA("BillboardGui") and (gui.Name:find("YoxanX")) then
				gui:Destroy()
			end
		end
	end
end

CleanupUI()
PrintToggles()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Create bullet tracer beam
local function CreateTracer(startPos, endPos, color)
	local beamPart = Instance.new("Part")
	beamPart.Anchored = true
	beamPart.CanCollide = false
	beamPart.Transparency = 0.5
	beamPart.Color = color or Color3.fromRGB(255, 50, 50)
	beamPart.Material = Enum.Material.Neon
	beamPart.Size = Vector3.new(0.1, 0.1, (startPos - endPos).Magnitude)
	beamPart.CFrame = CFrame.new(startPos, endPos) * CFrame.new(0, 0, -beamPart.Size.Z / 2)
	beamPart.Parent = Workspace

	game:GetService("Debris"):AddItem(beamPart, 0.25)
end

-- Hitstun FX
local function ShowHitText(target)
	if not target.Character then return end
	local head = target.Character:FindFirstChild("Head")
	if not head then return end

	local gui = Instance.new("BillboardGui", head)
	gui.Name = "YoxanX_HitFX"
	gui.Size = UDim2.new(0, 100, 0, 40)
	gui.Adornee = head
	gui.AlwaysOnTop = true

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "HIT!"
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 0, 0)

	TweenService:Create(label, TweenInfo.new(0.4), {
		TextTransparency = 1,
		Position = UDim2.new(0, 0, -1, 0)
	}):Play()

	game:GetService("Debris"):AddItem(gui, 0.5)
end

-- Multi Target Fire Logic
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.Enabled or not getgenv().YoxanXSettings.SilentAim then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then
			local head = plr.Character.Head
			if (head.Position - Camera.CFrame.Position).Magnitude < 500 then
				if getgenv().YoxanXSettings.MultiTarget then
					CreateTracer(Camera.CFrame.Position, head.Position)
					ShowHitText(plr)
				end
			end
		end
	end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Freeze detection logic
local freezeTracker = {}
local freezeThreshold = 3 -- seconds

local function GetESPColor(targetPlayer)
	if targetPlayer.Team ~= nil and LocalPlayer.Team ~= nil and targetPlayer.Team == LocalPlayer.Team then
		return Color3.fromRGB(0, 255, 0) -- Green for teammate
	else
		return Color3.fromRGB(255, 0, 0) -- Red for enemy
	end
end

local function CreateBoxESP(char, color)
	if not char:FindFirstChild("HumanoidRootPart") then return end

	local adorn = Instance.new("BoxHandleAdornment")
	adorn.Name = "YoxanX_ESP"
	adorn.Adornee = char.HumanoidRootPart
	adorn.Size = Vector3.new(4, 6, 2)
	adorn.Color3 = color
	adorn.AlwaysOnTop = true
	adorn.ZIndex = 10
	adorn.Transparency = 0.3
	adorn.Parent = char
end

local function CreateLineESP(char, color)
	if not char:FindFirstChild("HumanoidRootPart") then return end

	local beam = Instance.new("Beam", char.HumanoidRootPart)
	local a0 = Instance.new("Attachment", Camera)
	local a1 = Instance.new("Attachment", char.HumanoidRootPart)

	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.FaceCamera = true
	beam.Color = ColorSequence.new(color)
	beam.Width0 = 0.05
	beam.Width1 = 0.05

	game:GetService("Debris"):AddItem(beam, 0.5)
end

RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.ESP then return end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			if not p.Character:FindFirstChild("YoxanX_ESP") then
				local espColor = GetESPColor(p)
				CreateBoxESP(p.Character, espColor)
				CreateLineESP(p.Character, espColor)
			end

			-- Freeze check
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local id = tostring(p)
				local last = freezeTracker[id]
				if last then
					if (last - root.Position).Magnitude < 0.5 then
						if not p.Character:FindFirstChild("FrozenTag") then
							local tag = Instance.new("BoolValue", p.Character)
							tag.Name = "FrozenTag"
							print(p.Name .. " might be frozen.")
						end
					else
						local ftag = p.Character:FindFirstChild("FrozenTag")
						if ftag then ftag:Destroy() end
					end
				end
				freezeTracker[id] = root.Position
			end
		end
	end
end)

-- High Ping Notification
local function CheckPing()
	local Stats = game:GetService("Stats")
	local pingStat = Stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem"):FindFirstChild("Data Ping")
	if pingStat and pingStat:GetValue() > 200 then
		local OrionLib = getgenv().OrionLib
		if OrionLib then
			OrionLib:MakeNotification({
				Name = "High Ping!",
				Content = "Your ping is above 200ms. Aim might delay.",
				Image = "rbxassetid://7733960981",
				Time = 4
			})
		end
	end
end

while true do
	task.wait(15)
	pcall(CheckPing)
end

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function GetPriorityTarget()
	local closestScore = math.huge
	local chosen = nil

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("Head") then
			local head = p.Character.Head
			local hp = p.Character.Humanoid.Health
			local dist = (head.Position - Camera.CFrame.Position).Magnitude
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

			if onScreen and dist < 500 then
				if getgenv().YoxanXSettings.VisibleOnly then
					local rayParams = RaycastParams.new()
					rayParams.FilterDescendantsInstances = {Camera, LocalPlayer.Character}
					rayParams.FilterType = Enum.RaycastFilterType.Blacklist
					local ray = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * dist, rayParams)
					if ray and not ray.Instance:IsDescendantOf(p.Character) then continue end
				end

				-- Ping weight multiplier
				local pingFactor = math.clamp((game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() or 0) / 100, 1, 3)
				local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

				local totalScore = (dist * 0.4 + hp * 0.3 + screenDist * 0.3) * pingFactor
				if totalScore < closestScore then
					closestScore = totalScore
					chosen = p
				end
			end
		end
	end

	return chosen
end

-- Sticky target focus system
local currentLocked = nil

game:GetService("RunService").RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings.Enabled then return end
	if currentLocked and currentLocked.Character and currentLocked.Character:FindFirstChild("Humanoid") then
		if currentLocked.Character.Humanoid.Health <= 0 then
			currentLocked = nil
		end
	end

	if not currentLocked or not getgenv().YoxanXSettings.StickyLock then
		currentLocked = GetPriorityTarget()
	end

	getgenv().YoxanX_Target = currentLocked
end)

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- FX: Headshot Confirm
local function ShowHeadshotFX(target)
	if not target.Character or not target.Character:FindFirstChild("Head") then return end
	local head = target.Character.Head

	local gui = Instance.new("BillboardGui", head)
	gui.Size = UDim2.new(0, 100, 0, 40)
	gui.Adornee = head
	gui.AlwaysOnTop = true
	gui.Name = "YoxanX_HeadshotFX"

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "💥 HEADSHOT!"
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 80, 80)

	TweenService:Create(label, TweenInfo.new(0.3), {
		TextTransparency = 1,
		Position = UDim2.new(0, 0, -1.5, 0)
	}):Play()

	Debris:AddItem(gui, 0.6)
end

-- FX: Kill Confirm
local function ShowKillFX(target)
	if not target.Character or not target.Character:FindFirstChild("Head") then return end
	local head = target.Character.Head

	local gui = Instance.new("BillboardGui", head)
	gui.Size = UDim2.new(0, 80, 0, 30)
	gui.Adornee = head
	gui.AlwaysOnTop = true
	gui.Name = "YoxanX_KillFX"

	local label = Instance.new("TextLabel", gui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "☠️ DEAD"
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(180, 0, 0)

	TweenService:Create(label, TweenInfo.new(0.4), {
		TextTransparency = 1,
		Position = UDim2.new(0, 0, -1, 0)
	}):Play()

	Debris:AddItem(gui, 0.8)
end

-- Handler (triggered after damage)
local function OnTargetDamaged(target, headshot)
	if headshot then
		ShowHeadshotFX(target)
	end
	if target and target.Character and target.Character:FindFirstChild("Humanoid") then
		if target.Character.Humanoid.Health <= 0 then
			ShowKillFX(target)
			if getgenv().YoxanXSettings.AntiOverkill then
				getgenv().YoxanX_Target = nil -- switch to new target
			end
		end
	end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Lead time predictor
local function PredictHeadPosition(target)
	if not target.Character or not target.Character:FindFirstChild("Head") then return nil end

	local head = target.Character.Head
	local velocity = head.Velocity or Vector3.zero
	local distance = (head.Position - Camera.CFrame.Position).Magnitude

	-- Ping delay
	local Stats = game:GetService("Stats")
	local ping = 0
	pcall(function()
		ping = Stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem"):FindFirstChild("Data Ping"):GetValue()
	end)
	ping = math.clamp(ping or 0, 0, 400)
	local delay = (ping / 1000) + 0.03 -- smart wait logic

	-- Estimate future position based on movement
	local leadFactor = math.clamp(distance / 100, 0.5, 3)
	local predicted = head.Position + (velocity * delay * leadFactor)
	return predicted
end

-- Use in place of: head.Position → PredictHeadPosition(target)
getgenv().YoxanX_PredictHead = PredictHeadPosition

-- TEST SYSTEM: Auto render tracer for predicted hit
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings or not getgenv().YoxanXSettings.Enabled then return end
	local target = getgenv().YoxanX_Target
	if target and getgenv().YoxanXSettings.PredictionDemo then
		local predicted = PredictHeadPosition(target)
		if predicted then
			local part = Instance.new("Part", workspace)
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new(0.4, 0.4, 0.4)
			part.Shape = Enum.PartType.Ball
			part.Material = Enum.Material.Neon
			part.BrickColor = BrickColor.new("Bright red")
			part.Position = predicted
			game:GetService("Debris"):AddItem(part, 0.2)
		end
	end
end)

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Crosshair UI
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "YoxanXCrosshair"
screenGui.ResetOnSpawn = false

local crossLabel = Instance.new("TextLabel", screenGui)
crossLabel.Size = UDim2.new(0, 200, 0, 40)
crossLabel.Position = UDim2.new(0.5, -100, 0.5, -100)
crossLabel.BackgroundTransparency = 1
crossLabel.Text = ""
crossLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
crossLabel.TextScaled = true
crossLabel.Font = Enum.Font.GothamBold

-- Pulse FX on target
local function CreatePulseFX(targetChar)
	if targetChar:FindFirstChild("HumanoidRootPart") and not targetChar:FindFirstChild("YoxanX_Pulse") then
		local pulse = Instance.new("Part", targetChar)
		pulse.Name = "YoxanX_Pulse"
		pulse.Shape = Enum.PartType.Ball
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.Size = Vector3.new(2.5, 2.5, 2.5)
		pulse.Material = Enum.Material.Neon
		pulse.Transparency = 0.5
		pulse.Color = Color3.fromRGB(255, 80, 80)
		game:GetService("Debris"):AddItem(pulse, 0.4)

		pulse.CFrame = targetChar.HumanoidRootPart.CFrame

		local tween = game:GetService("TweenService"):Create(pulse, TweenInfo.new(0.3), {
			Size = Vector3.new(6, 6, 6),
			Transparency = 1
		})
		tween:Play()
	end
end

-- Render loop for crosshair and pulse FX
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings or not getgenv().YoxanXSettings.Enabled then
		crossLabel.Text = ""
		return
	end

	local target = getgenv().YoxanX_Target
	if target and target.Character and target.Character:FindFirstChild("Head") then
		crossLabel.Text = "🎯 LOCKED"
		CreatePulseFX(target.Character)
	else
		crossLabel.Text = ""
	end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Config
local alertRadius = 60
local wallTransparency = 0.5

-- Wall ESP Enhancer
local function MakeWallTransparentAround(target)
	if not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
	local root = target.Character.HumanoidRootPart
	local direction = (root.Position - Camera.CFrame.Position).Unit * 100
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {Camera, LocalPlayer.Character}

	local result = workspace:Raycast(Camera.CFrame.Position, direction, rayParams)
	if result and result.Instance and result.Instance:IsA("BasePart") then
		local part = result.Instance
		if not part:FindFirstChild("YoxanX_OriginalTransparency") then
			local tag = Instance.new("NumberValue", part)
			tag.Name = "YoxanX_OriginalTransparency"
			tag.Value = part.Transparency
			part.Transparency = wallTransparency
			game:GetService("Debris"):AddItem(tag, 1.5)
			task.delay(1.5, function()
				if tag and tag.Parent then
					tag.Parent.Transparency = tag.Value
					tag:Destroy()
				end
			end)
		end
	end
end

-- Alert Radius FX
local function DrawAlertCircle()
	local existing = workspace:FindFirstChild("YoxanX_AlertCircle")
	if existing then existing:Destroy() end

	local circle = Instance.new("Part", workspace)
	circle.Anchored = true
	circle.CanCollide = false
	circle.Shape = Enum.PartType.Cylinder
	circle.Size = Vector3.new(alertRadius * 2, 0.1, alertRadius * 2)
	circle.Material = Enum.Material.Neon
	circle.Color = Color3.fromRGB(255, 100, 100)
	circle.Transparency = 0.7
	circle.Orientation = Vector3.new(0, 0, 90)
	circle.Name = "YoxanX_AlertCircle"
	game:GetService("Debris"):AddItem(circle, 0.5)

	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		circle.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.5, 0))
	end
end

-- Visual Loop
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings or not getgenv().YoxanXSettings.Enabled then return end

	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if root then
		DrawAlertCircle()
	end

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (plr.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
			if dist <= 70 then
				MakeWallTransparentAround(plr)
			end
		end
	end
end)

local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ESP Config
local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "YoxanX_ESP"

local function CreateESP(player)
	local box = Drawing.new("Square")
	box.Visible = false
	box.Color = Color3.new(1, 0, 0)
	box.Thickness = 2
	box.Transparency = 1

	local nameTag = Drawing.new("Text")
	nameTag.Visible = false
	nameTag.Size = 14
	nameTag.Color = Color3.new(1, 0, 0)
	nameTag.Center = true
	nameTag.Outline = true
	nameTag.Text = ""

	local line = Drawing.new("Line")
	line.Visible = false
	line.Thickness = 1.5
	line.Color = Color3.new(1, 0, 0)
	line.Transparency = 1

	local hpBar = Drawing.new("Square")
	hpBar.Visible = false
	hpBar.Thickness = 1
	hpBar.Color = Color3.fromRGB(0, 255, 0)

	return {
		Player = player,
		Box = box,
		Name = nameTag,
		Line = line,
		HP = hpBar,
		LastPos = nil
	}
end

local espList = {}

-- ESP Loop
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings or not getgenv().YoxanXSettings.ESPEnabled then
		for _, esp in pairs(espList) do
			esp.Box.Visible = false
			esp.Name.Visible = false
			esp.Line.Visible = false
			esp.HP.Visible = false
		end
		return
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") then
			if not espList[plr] then espList[plr] = CreateESP(plr) end
			local esp = espList[plr]

			local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
			local hrp = plr.Character.HumanoidRootPart
			local size = Vector3.new(2, 3, 1.5)
			local pos, vis = Camera:WorldToViewportPoint(hrp.Position)

			if onScreen then
				local color = plr.Team ~= LocalPlayer.Team and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)

				-- Box
				esp.Box.Size = Vector2.new(60, 80)
				esp.Box.Position = Vector2.new(pos.X - 30, pos.Y - 60)
				esp.Box.Color = color
				esp.Box.Visible = true

				-- Name
				esp.Name.Position = Vector2.new(pos.X, pos.Y - 75)
				esp.Name.Text = plr.Name
				esp.Name.Color = color
				esp.Name.Visible = true

				-- Line
				esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				esp.Line.To = Vector2.new(pos.X, pos.Y)
				esp.Line.Color = color
				esp.Line.Visible = true

				-- HP Bar
				local hp = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
				local barHeight = 80 * hp
				esp.HP.Size = Vector2.new(4, barHeight)
				esp.HP.Position = Vector2.new(pos.X - 35, pos.Y - 40 + (80 - barHeight))
				esp.HP.Visible = true

				-- Freeze Check
				if esp.LastPos and (esp.LastPos - hrp.Position).Magnitude < 0.1 then
					esp.Name.Text = plr.Name .. " ❄️"
				end
				esp.LastPos = hrp.Position
			else
				esp.Box.Visible = false
				esp.Name.Visible = false
				esp.Line.Visible = false
				esp.HP.Visible = false
			end
		end
	end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Smart ping delay auto-adjust
local function GetSmartDelay()
	local Stats = game:GetService("Stats")
	local ping = 0
	pcall(function()
		ping = Stats:FindFirstChild("Network"):FindFirstChild("ServerStatsItem"):FindFirstChild("Data Ping"):GetValue()
	end)
	return math.clamp(ping / 1000 + 0.03, 0.03, 0.3)
end

getgenv().YoxanX_SmartDelay = GetSmartDelay

-- Smart ignore
local function ShouldIgnorePart(part)
	if not part:IsA("BasePart") then return true end
	if part.Transparency > 0.9 then return true end
	if part.Name:lower():find("shield") or part.Name:lower():find("block") then return true end
	if part:IsDescendantOf(LocalPlayer.Character) then return true end
	return false
end

-- Advanced 3D WallCheck
local function IsTargetVisible(targetPart)
	if not targetPart then return false end
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin).Unit * 1000

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
	rayParams.IgnoreWater = true

	local result = workspace:Raycast(origin, direction, rayParams)
	if result then
		local hitPart = result.Instance
		if hitPart:IsDescendantOf(targetPart.Parent) then
			return true
		elseif ShouldIgnorePart(hitPart) then
			return true
		end
		return false
	end
	return false
end

getgenv().YoxanX_IsVisible3D = IsTargetVisible

-- Anti-Flash Logic
LocalPlayer.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(obj)
		if obj:IsA("ScreenGui") and obj.Name:lower():find("flash") then
			obj:Destroy()
		end
	end)
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- UI Hitmarker Text
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "YoxanXHitUI"
gui.ResetOnSpawn = false

local hitLabel = Instance.new("TextLabel", gui)
hitLabel.Size = UDim2.new(0, 100, 0, 40)
hitLabel.Position = UDim2.new(0.5, -50, 0.8, 0)
hitLabel.Text = ""
hitLabel.TextScaled = true
hitLabel.BackgroundTransparency = 1
hitLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
hitLabel.Font = Enum.Font.GothamBold
hitLabel.Visible = false

-- Beam Trail
local function ShowBulletTrail(from, to)
	local beam = Instance.new("Part", workspace)
	beam.Anchored = true
	beam.CanCollide = false
	beam.Material = Enum.Material.Neon
	beam.Color = Color3.fromRGB(255, 0, 0)
	beam.Transparency = 0.2
	beam.Size = Vector3.new(0.15, 0.15, (from - to).Magnitude)
	beam.CFrame = CFrame.new(from, to) * CFrame.new(0, 0, -beam.Size.Z / 2)
	game:GetService("Debris"):AddItem(beam, 0.2)
end

-- Recoil Canceller
RunService.RenderStepped:Connect(function()
	if Camera:FindFirstChild("Recoil") then
		Camera.Recoil:Destroy()
	end
end)

-- Hitmarker Display
function getgenv().YoxanX_ShowHit()
	hitLabel.Text = "Hit!"
	hitLabel.Visible = true
	local tween = TweenService:Create(hitLabel, TweenInfo.new(0.2), {TextTransparency = 0.2})
	tween:Play()
	tween.Completed:Wait()
	task.delay(0.2, function()
		local outTween = TweenService:Create(hitLabel, TweenInfo.new(0.2), {TextTransparency = 1})
		outTween:Play()
		outTween.Completed:Wait()
		hitLabel.Visible = false
	end)
end

-- Bullet effect trigger
function getgenv().YoxanX_BulletFX(from, to)
	ShowBulletTrail(from, to)
	getgenv().YoxanX_ShowHit()
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Notification UI (Cross Notify)
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "YoxanXNotifyUI"
gui.ResetOnSpawn = false

local notif = Instance.new("TextLabel", gui)
notif.Size = UDim2.new(0, 240, 0, 30)
notif.Position = UDim2.new(0.5, -120, 0.35, 0)
notif.BackgroundTransparency = 0.4
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BorderSizePixel = 0
notif.TextColor3 = Color3.fromRGB(255, 255, 255)
notif.TextScaled = true
notif.Text = ""
notif.Visible = false
notif.Font = Enum.Font.GothamBold

function getgenv().YoxanX_Notify(txt)
	notif.Text = txt
	notif.Visible = true
	local t1 = TweenService:Create(notif, TweenInfo.new(0.3), {TextTransparency = 0})
	t1:Play()
	t1.Completed:Wait()
	wait(1.5)
	local t2 = TweenService:Create(notif, TweenInfo.new(0.3), {TextTransparency = 1})
	t2:Play()
	t2.Completed:Wait()
	notif.Visible = false
end

-- Directional FX: Arrow to target
local arrow = Drawing.new("Line")
arrow.Visible = false
arrow.Thickness = 2
arrow.Color = Color3.fromRGB(255, 100, 100)

-- Update arrow each frame
RunService.RenderStepped:Connect(function()
	if not getgenv().YoxanXSettings or not getgenv().YoxanXSettings.Enabled then
		arrow.Visible = false
		return
	end

	local target = getgenv().YoxanX_Target
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		local pos, onScreen = Camera:WorldToViewportPoint(target.Character.HumanoidRootPart.Position)
		if onScreen then
			arrow.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
			arrow.To = Vector2.new(pos.X, pos.Y)
			arrow.Visible = true
		else
			arrow.Visible = false
		end
	else
		arrow.Visible = false
	end
end)

-- Auto Target Switch Logic
RunService.Heartbeat:Connect(function()
	local target = getgenv().YoxanX_Target
	if target and (not target.Character or target.Character:FindFirstChild("Humanoid") and target.Character.Humanoid.Health <= 0) then
		getgenv().YoxanX_Target = nil
		getgenv().YoxanX_Notify("🔄 Switching Target...")
	end
end)
