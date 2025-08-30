local Buttons = {}

function Buttons.init(Window)
   
    local Tab = Window:FindFirstChild("Main") or Window.Tabs[1]

  
    Tab:CreateButton({
        Name = "Test!",
        Callback = function()
            print("Button clicked!")
        end
    })
end

return Buttons
