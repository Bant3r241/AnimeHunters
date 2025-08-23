if game.PlaceId == 118554563202898 then
    -- Attempt to load OrionLib safely and ensure it's loaded properly
    local OrionLib
    local success, errorMsg = pcall(function()
        OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
    end)

    -- Handle errors if OrionLib fails to load
    if not success then
        warn("Failed to load OrionLib: " .. errorMsg)
        return
    end

    local Window = OrionLib:MakeWindow({
        Name="ABI │ AnimeHunters", 
        HidePremium=false, 
        IntroEnabled=false, 
        IntroText="ABI", 
        SaveConfig=true, 
        ConfigFolder="XlurConfig"
    })

    -- Tabs
    local MainTab = Window:MakeTab({Name="Main", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local EspTab = Window:MakeTab({Name="ESP", Icon="rbxassetid://4299432428", PremiumOnly=false})
    local MiscTab = Window:MakeTab({Name="Misc", Icon="rbxassetid://4299432428", PremiumOnly=false})

    
    })

    -- ESP Tab Toggles

    -- Player ESP toggle (your existing)
    EspTab:AddToggle({
        Name = "Player ESP",
        Default = false,
        Callback = function(v)
            if v then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Bant3r241/chams/refs/heads/main/ESP.lua"))()
            end
        end
    })

    

    -- Initialize the OrionLib UI
    OrionLib:Init()
end
