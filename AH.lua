local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

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

local mainUICorner = Instance.new("UICorner")
mainUICorner.CornerRadius = UDim.new(0, 8)
mainUICorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Server Hop for Brole"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Center

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 ON"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

local broleHealthLabel = Instance.new("TextLabel", mainFrame)
broleHealthLabel.Size = UDim2.new(1, 0, 0, 30)
broleHealthLabel.Position = UDim2.new(0, 0, 0, 60)
broleHealthLabel.BackgroundTransparency = 1
broleHealthLabel.Text = "Brole's Health: N/A"
broleHealthLabel.Font = Enum.Font.Gotham
broleHealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
broleHealthLabel.TextSize = 16
broleHealthLabel.TextXAlignment = Enum.TextXAlignment.Center

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

local keybindLabel = Instance.new("TextLabel", mainFrame)
keybindLabel.Size = UDim2.new(1, 0, 0, 20)
keybindLabel.Position = UDim2.new(0, 0, 1, -20)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Text = "Press F to turn ON/OFF"
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
keybindLabel.TextSize = 14
keybindLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Drag logic
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

-- Variables
local serverHopEnabled = true
local running = false

-- Health Label reference path
local healthLabel = playerGui:WaitForChild("HUDS"):WaitForChild("HUD"):WaitForChild("Frame"):WaitForChild("Health"):WaitForChild("Container"):WaitForChild("Value")

local function getNumbersFromText(text)
    local numbers = {}
    for num in text:gmatch("%d+%.?%d*") do
        table.insert(numbers, tonumber(num))
    end
    return numbers
end

local function getBroleHealth()
    local rawText = healthLabel.Text
    local numbers = getNumbersFromText(rawText)

    if #numbers >= 2 then
        local current = numbers[1]
        local max = numbers[2]
        return current, max
    else
        return nil, nil
    end
end

-- Notification helper
local function notify(message)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 250, 0, 40)
    notification.Position = UDim2.new(1, -260, 1, -50)
    notification.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    notification.TextColor3 = Color3.fromRGB(0, 0, 0)
    notification.Font = Enum.Font.GothamBold
    notification.TextSize = 18
    notification.Text = message
    notification.TextXAlignment = Enum.TextXAlignment.Center
    notification.TextYAlignment = Enum.TextYAlignment.Center
    notification.Parent = screenGui

    local tween = TweenService:Create(notification, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1, BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Server Hop logic variables
local currentJobId = game.JobId
local placeId = game.PlaceId
local visitedServers = {}

-- Function to get servers list (Roblox API)
local function getServers()
    local servers = {}
    local success, response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        for _, server in pairs(data.data) do
            if server.id ~= currentJobId and server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
    else
        warn("Failed to get servers list")
    end
    return servers
end

-- Hop to next server
local function serverHop()
    local servers = getServers()
    for _, serverId in ipairs(servers) do
        if not visitedServers[serverId] then
            visitedServers[serverId] = true
            print("Teleporting to server:", serverId)
            TeleportService:TeleportToPlaceInstance(placeId, serverId, player)
            return true
        end
    end
    return false -- no server found to hop
end

-- Main Loop
local function mainLoop()
    while running do
        local current, max = getBroleHealth()
        if current and max then
            broleHealthLabel.Text = string.format("Brole's Health: %.2f / %.2f", current, max)
            if current > 0 then
                notify("Brole Alive!!!")
                print("Brole alive! Stopping server hop.")
                serverHopEnabled = false
                running = false
                updateUI()
                break
            else
                print("Brole health is zero, hopping servers...")
                wait(2)
                local success = serverHop()
                if not success then
                    print("No more servers to hop. Resetting visited list.")
                    visitedServers = {}
                end
                break -- after teleport, stop current loop, it will restart on new server
            end
        else
            broleHealthLabel.Text = "Brole's Health: N/A"
            print("Unable to detect Brole's health, hopping anyway...")
            wait(2)
            local success = serverHop()
            if not success then
                print("No more servers to hop. Resetting visited list.")
                visitedServers = {}
            end
            break
        end
        wait(1)
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
        running = true
        task.spawn(function()
            while running do
                mainLoop()
                task.wait(1)
            end
        end)
    else
        print("Server Hop Disabled")
        running = false
    end
end

toggleButton.MouseButton1Click:Connect(toggleServerHop)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        toggleServerHop()
    end
end)

-- Initialize
updateUI()
if serverHopEnabled then
    running = true
    task.spawn(function()
        while running do
            mainLoop()
            task.wait(1)
        end
    end)
end
