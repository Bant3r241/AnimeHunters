-- ServerHopGUI Module

local ServerHopGUI = {}

function ServerHopGUI.createGUI(player)
    -- Create the ScreenGui
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "ServerHopForBrolev2GUI"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 9999

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 180)
    mainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.Active = true

    local mainUICorner = Instance.new("UICorner")
    mainUICorner.CornerRadius = UDim.new(0, 8)
    mainUICorner.Parent = mainFrame

    -- Title Label
    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Text = "Server Hop for Brole"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18

    -- Status Label (ON/OFF Indicator)
    local statusLabel = Instance.new("TextLabel", mainFrame)
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 35)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 16
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Text = "🟢 ON"  -- Default status (you can set it to OFF initially)

    -- Toggle Button
    local toggleButton = Instance.new("TextButton", mainFrame)
    toggleButton.Size = UDim2.new(0.85, 0, 0, 40)
    toggleButton.Position = UDim2.new(0.075, 0, 0.75, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "Turn OFF"
    toggleButton.TextSize = 18
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = true

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 8)
    uicorner.Parent = toggleButton

    -- Keybind Label
    local keybindLabel = Instance.new("TextLabel", mainFrame)
    keybindLabel.Size = UDim2.new(1, 0, 0, 20)
    keybindLabel.Position = UDim2.new(0, 0, 1, -20)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Text = "Press F to turn ON/OFF"
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    keybindLabel.TextSize = 14

    return screenGui, mainFrame, statusLabel, toggleButton
end

return ServerHopGUI
