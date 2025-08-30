local Tabs = {}

function Tabs.init(Window)
    -- Example Tab
    Tabs.MainTab = Window:CreateTab("Misc", {
        Icon = "rbxassetid://123456789",
        Unload = false
    })
end

return Tabs
