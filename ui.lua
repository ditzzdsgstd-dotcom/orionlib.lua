repeat wait() until game:IsLoaded()
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
end)
if not success then
    return warn("⚠️ Failed to load OrionLib.")
end

local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub V2.5+ | Hypershot Gunfight",
    HidePremium = false,
    IntroEnabled = true,
    IntroText = "YoxanXHub V2.5 Loading...",
    SaveConfig = true,
    ConfigFolder = "YoxanXHub"
})

-- 🧠 Tabs
local Tab_Main = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://6035078888", PremiumOnly = false})
local Tab_Visual = Window:MakeTab({Name = "Visual", Icon = "rbxassetid://6035193209", PremiumOnly = false})
local Tab_Safety = Window:MakeTab({Name = "Safety", Icon = "rbxassetid://6035191556", PremiumOnly = false})
local Tab_Info = Window:MakeTab({Name = "Info", Icon = "rbxassetid://6031091002", PremiumOnly = false})
local Tab_Debug = Window:MakeTab({Name = "Debug", Icon = "rbxassetid://6035275664", PremiumOnly = false})

-- 🧠 Global Settings
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
    AutoLeaveOnMod = false,
}

-- 🔔 UI Load Notification
OrionLib:MakeNotification({
    Name = "YoxanXHub V2.5 Loaded",
    Content = "Ready to destroy.",
    Image = "rbxassetid://6035193209",
    Time = 4
})
