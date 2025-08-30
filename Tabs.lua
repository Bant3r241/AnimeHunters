return function(Window, OrionLib)
    local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998"})
    
    MainTab:AddButton({
        Name = "Example Button",
        Callback = function()
            print("Button clicked!")
        end
    })
    
    local ESPTab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998"})
    
    ESPTab:AddToggle({
        Name = "Player ESP",
        Default = false,
        Callback = function(Value)
            print("ESP:", Value)
        end
    })
    
    local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})
    
    SettingsTab:AddKeybind({
        Name = "UI Toggle Key",
        Default = Enum.KeyCode.RightShift,
        Callback = function()
            Window:Toggle()
        end
    })
end
