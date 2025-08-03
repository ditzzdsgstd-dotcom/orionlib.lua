-- YoxanXHub | Silent Aim UI - Part 1/5
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ditzzdsgstd-dotcom/orionlib.lua/main/orionlibv1.lua"))()
local win = OrionLib:MakeWindow({
	Name = "YoxanXHub | Silent Aim",
	HidePremium = false,
	SaveConfig = false,
	ConfigFolder = "YoxanX_SilentAim"
})

getgenv().SilentAimSettings = {
	Enabled = false,
	FOV = 100,
	ShowFOV = true,
	TargetPart = "Head",
	TeamCheck = false
}

local MainTab = win:MakeTab({
	Name = "Silent Aim",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MainTab:AddToggle({
	Name = "Enable Silent Aim",
	Default = false,
	Callback = function(v)
		getgenv().SilentAimSettings.Enabled = v
	end
})

MainTab:AddToggle({
	Name = "Show FOV Circle",
	Default = true,
	Callback = function(v)
		getgenv().SilentAimSettings.ShowFOV = v
	end
})

MainTab:AddSlider({
	Name = "FOV Size",
	Min = 50,
	Max = 250,
	Default = 100,
	Color = Color3.fromRGB(0, 200, 255),
	Increment = 5,
	ValueName = "px",
	Callback = function(v)
		getgenv().SilentAimSettings.FOV = v
	end
})
