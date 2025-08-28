local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Create GUI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "ServerHopForBroleGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999  -- Very high to stay on top

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 180)
mainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true  -- Needed for input detection

-- Rounded corners for main frame
local mainUICorner = Instance.new("UICorner")
mainUICorner.CornerRadius = UDim.new(0, 8)
mainUICorner.Parent = mainFrame

-- Title Label
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Server Hop for Brole"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Status Label
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 ON"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Brole Health Label
local broleHealthLabel = Instance.new("TextLabel", mainFrame)
broleHealthLabel.Size = UDim2.new(1, 0, 0, 30)
broleHealthLabel.Position = UDim2.new(0, 0, 0, 60)
broleHealthLabel.BackgroundTransparency = 1
broleHealthLabel.Text = "Brole's Health: N/A"
broleHealthLabel.Font = Enum.Font.Gotham
broleHealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
broleHealthLabel.TextSize = 16
broleHealthLabel.TextXAlignment = Enum.TextXAlignment.Center

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
keybindLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Variables for drag
local dragging = false
local dragInput, dragStart, startPos

local function updatePosition(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updatePosition(input)
    end
end)

-- Server Hop toggle state
local serverHopEnabled = true -- ON by default
local running = false

-- Health Label reference path (adjust if needed)
local healthLabel = playerGui:WaitForChild("HUDS"):WaitForChild("HUD"):WaitForChild("Frame"):WaitForChild("Health"):WaitForChild("Container"):WaitForChild("Value")

local function parseDecimalNumber(text)
    local numStr = text:match("([%d%.]+)")
    return tonumber(numStr)
end

local function getBroleHealth()
    local rawText = healthLabel.Text
    local leftPart, rightPart = rawText:match("([^/]+)%s*/%s*([^/]+)")
    if not leftPart or not rightPart then
        return nil, nil
    end

    local current = parseDecimalNumber(leftPart)
    local max = parseDecimalNumber(rightPart)

    return current, max
end

-- Loop to update Brole's health every second
local function healthCheckLoop()
    while running do
        local current, max = getBroleHealth()
        if current and max then
            broleHealthLabel.Text = string.format("Brole's Health: %.2f / %.2f", current, max)
        else
            broleHealthLabel.Text = "Brole's Health: N/A"
        end
        task.wait(1)
    end
end

local function updateUI()
    if serverHopEnabled then
        statusLabel.Text = "🟢 ON"
        toggleButton.Text = "Turn OFF"
    else
        statusLabel.Text = "🔴 OFF"
        toggleButton.Text = "Turn ON"
        broleHealthLabel.Text = "Brole's Health: N/A"
    end
end

local function toggleServerHop()
    serverHopEnabled = not serverHopEnabled
    updateUI()
    if serverHopEnabled then
        print("Server Hop Enabled")
        if not running then
            running = true
            task.spawn(healthCheckLoop)
        end
    else
        print("Server Hop Disabled")
        running = false
    end
end

-- Button Click
toggleButton.MouseButton1Click:Connect(toggleServerHop)

-- Keybind (F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        toggleServerHop()
    end
end)

-- Initialize UI state and start health loop
updateUI()
if serverHopEnabled then
    running = true
    task.spawn(healthCheckLoop)
end
