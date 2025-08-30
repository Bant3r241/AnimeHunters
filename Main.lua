
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/Rayfield-Scripts/main/Rayfield.lua"))()


local Window = Rayfield:CreateWindow({
    Name = "Anime Hunters",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Please wait...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "RayfieldConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        Version = "1.0"
    }
})


local Tabs = require(game:GetService("ReplicatedStorage"):WaitForChild("Tabs"))
local Toggles = require(game:GetService("ReplicatedStorage"):WaitForChild("Toggles"))
local Buttons = require(game:GetService("ReplicatedStorage"):WaitForChild("Buttons"))


Tabs.init(Window)


Toggles.init(Window)


Buttons.init(Window)


0_Main.lua
Tabs/
Toggles/
Buttons/
