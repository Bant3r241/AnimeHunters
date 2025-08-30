local Toggles = {}

function Toggles.init(Window)
    -- Make sure the tab exists
    local Tab = Window:FindFirstChild("Main") or Window.Tabs[1]

    -- Example Toggle
    Tab:CreateToggle({
        Name = "Test Toggle",
        CurrentValue = false,
        Flag = "ExampleToggle",
        Callback = function(Value)
            print("Toggle value:", Value)
        end
    })
end

return Toggles
