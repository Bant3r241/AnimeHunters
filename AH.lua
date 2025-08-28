local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
end)

if not success then
    warn("OrionLib failed to load!")
    return
end

print("OrionLib Loaded Successfully!")

local Window = OrionLib:MakeWindow({
    Name = "ABI │ AnimeHunters",
    HidePremium = false,
    IntroEnabled = false,
    IntroText = "ABI",
    SaveConfig = true,
    ConfigFolder = "XlurConfig"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MiscTab:AddToggle({
    Name = "Server Hop",
    Default = false,
    Callback = function(Value)
        -- Placeholder for Server Hop logic (to be added later)
    end
})

OrionLib:MakeNotification({
    Name = "ABI",
    Content = "Loading Script!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:Init()
