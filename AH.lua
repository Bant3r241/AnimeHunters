local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
end)

if not success then
    warn("OrionLib failed to load!")
    return
end

print("OrionLib Loaded Successfully!")

local Window = OrionLib:MakeWindow({
    Name = "ABI │ AnimeHuntersRs",
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

-- Server Hop Toggle
MiscTab:AddToggle({
    Name = "Server Hop",
    Default = false,
    Callback = function(Value)
        if Value then
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            local currentJobId = game.JobId
            local placeId = game.PlaceId

            local success, response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
            end)

            if success and response and response.data then
                for _, server in ipairs(response.data) do
                    if server.playing < server.maxPlayers and server.id ~= currentJobId then
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
                        break
                    end
                end
            else
                warn("Failed to retrieve server list.")
            end
        end
    end
})

OrionLib:MakeNotification({
    Name = "ABI",
    Content = "Loading Script!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:Init()
