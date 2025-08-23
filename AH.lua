local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
end)

if not success then
    warn("OrionLib failed to load!")
    return
end

print("OrionLib Loaded Successfully!")

local Window = OrionLib:MakeWindow({
    Name = "ABI │ AnimeHunters", HidePremium = false, IntroEnabled = false, IntroText = "ABI", SaveConfig = true, ConfigFolder = "XlurConfig"
})
local Tab = Window:MakeTab({
    Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false
})

OrionLib:MakeNotification({Name = "ABI", Content = "Loading Script!", Image = "rbxassetid://4483345998", Time = 5})
OrionLib:Init()

-- Function to get unique enemy names from the specified path in the workspace
local function getUniqueEnemyNames()
    local uniqueNames = {}
    
    -- Accessing the enemies path
    local enemiesFolder = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
    if enemiesFolder then
        local saiyanGrounds = enemiesFolder:FindFirstChild("Saiyan Grounds")
        if saiyanGrounds then
            -- Traverse all models in Saiyan Grounds
            for _, enemy in pairs(saiyanGrounds:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("Name") then
                    local enemyName = enemy.Name
                    if not uniqueNames[enemyName] then
                        uniqueNames[enemyName] = true  -- Add enemy name to the uniqueNames table
                    end
                end
            end
        end
    end
    
    -- Convert table keys (enemy names) to a list
    local options = {}
    for name, _ in pairs(uniqueNames) do
        table.insert(options, name)
    end
    
    return options
end

-- Get the list of unique enemy names
local options = getUniqueEnemyNames()

-- Dropdown UI creation using OrionLib's dropdown feature
local selectedOption = OrionLib:MakeDropdown({
    Name = "Select Enemy",
    Options = options,
    Default = options[1], -- Set the first enemy as the default option
    Callback = function(option)
        print("Selected enemy: " .. option) -- Handle the selected option
    end
})

-- Optionally, add a label to show the selected enemy
local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(0, 300, 0, 30)
SelectedLabel.Position = UDim2.new(0.5, -150, 0.9, -30)
SelectedLabel.BackgroundTransparency, SelectedLabel.TextColor3 = 1, Color3.fromRGB(255, 255, 255)
SelectedLabel.Text = "Selected: None"
SelectedLabel.Parent = Window

-- Update the label when a new enemy is selected
selectedOption.Callback = function(option)
    SelectedLabel.Text = "Selected: " .. option
end
