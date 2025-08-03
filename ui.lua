-- YoxanXHub | Hypershot Gunfight V2.5 (1/25)
-- OrionLib Init + Loading + UI Tabs + Global Settings

repeat task.wait() until game:IsLoaded()

-- Loading UI dulu sebelum semua
local loadingGui = Instance.new("ScreenGui", game.CoreGui)
loadingGui.Name = "YoxanXLoading"

local label = Instance.new("TextLabel", loadingGui)
label.Size = UDim2.new(0, 300, 0, 50)
label.Position = UDim2.new(0.5, -150, 0.5, -25)
label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
label.BorderSizePixel = 0
label.TextColor3 = Color3.new(1,1,1)
label.TextScaled = true
label.Font = Enum.Font.GothamBlack
label.Text = "Loading YoxanXHub V2.5..."
label.ZIndex = 999

-- Load OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ditzzdsgstd-dotcom/orionlib.lua/main/orionlib.lua"))()

task.wait(1.5) -- delay agar Orion siap

-- Create window
local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub V2.5 | Hypershot Gunfight",
	HidePremium = false,
	IntroEnabled = true,
	IntroText = "YoxanXHub V2.5 Loading...",
	SaveConfig = false,
	ConfigFolder = "YoxanXConfig"
})

-- Hapus loading UI
loadingGui:Destroy()

-- Buat Tab
local Tab_Main = Window:MakeTab({Name = "Main", Icon = "rbxassetid://6035185487", PremiumOnly = false})
local Tab_Visual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://6031265976", PremiumOnly = false})
local Tab_Safety = Window:MakeTab({Name = "Safety", Icon = "rbxassetid://6035192843", PremiumOnly = false})
local Tab_Debug = Window:MakeTab({Name = "Debug", Icon = "rbxassetid://6035047377", PremiumOnly = false})

-- Setting awal
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

-- Notif UI muncul
OrionLib:MakeNotification({
	Name = "YoxanXHub V2.5 Loaded",
	Content = "Ready to use.",
	Image = "rbxassetid://6035185487",
	Time = 4
})
