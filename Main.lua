local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

-- Create main window
local Window = OrionLib:MakeWindow({
    Name = "Anime Hunters", 
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AnimeHuntersConfig",
    IntroEnabled = true
})

-- Load tabs from Tabs.lua
local LoadTabs = loadstring(game:HttpGet("https://raw.githubusercontent.com/Bant3r241/AnimeHunters/main/Tabs.lua"))()
LoadTabs(Window, OrionLib)

-- Initialize UI
OrionLib:Init()
