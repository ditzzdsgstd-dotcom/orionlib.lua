repeat wait() until game:IsLoaded()
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
end)
if not success then
    return warn("⚠️ Failed to load OrionLib. Please check your connection.")
end

local Window = OrionLib:MakeWindow({
	Name = "YoxanXHub - Hypershot Gunfight V2",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "YoxanXHub"
})

OrionLib:MakeNotification({
	Name = "YoxanXHub V2 Loaded",
	Content = "Ready to use!",
	Image = "rbxassetid://4483345998",
	Time = 4
})

-- lanjutkan fitur lainnya di bawah sini (Silent Aim, ESP, dll)
