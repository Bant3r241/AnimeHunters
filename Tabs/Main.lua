local Tabs = {}

function Tabs.init(Window)

    Tabs.MainTab = Window:CreateTab("Main", {
        Icon = "rbxassetid://123456789",
        Unload = false
    })
end

return Tabs
