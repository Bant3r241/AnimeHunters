local Toggles = {}

function Toggles.init(Window)
    
    local Tab = Window:FindFirstChild("Main") or Window.Tabs[1]

   
    Tab:CreateToggle({
        Name = "Example Toggle",
        CurrentValue = false,
        Flag = "ExampleToggle",
        Callback = function(Value)
            print("Toggle value:", Value)
        end
    })
end

return Toggles
