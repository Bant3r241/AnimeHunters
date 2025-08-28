local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Constants
local PLACE_ID = game.PlaceId
local COOLDOWN_TIME = 120 -- seconds cooldown for revisiting servers

-- State
local running = false
local visitedServers = {}

-- GUI Creation --

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "ServerHopGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 150)
mainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

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
statusLabel.Text = "🔴 OFF"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 16
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

local toggleButton = Instance.new("TextButton", mainFrame)
toggleButton.Size = UDim2.new(0.85, 0, 0, 40)
toggleButton.Position = UDim2.new(0.075, 0, 0.55, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Start Server Hop"
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
keybindLabel.Text = "Press F to toggle"
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
keybindLabel.TextSize = 14
keybindLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Notification function --
local function makeNotification(text, color)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 250, 0, 40)
    notif.Position = UDim2.new(1, -260, 1, -50)
    notif.BackgroundColor3 = color or Color3.fromRGB(0, 170, 0)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Font = Enum.Font.Gotham
    notif.TextSize = 18
    notif.Text = text
    notif.TextXAlignment = Enum.TextXAlignment.Center
    notif.TextYAlignment = Enum.TextYAlignment.Center
    notif.Parent = playerGui

    local tween = TweenService:Create(notif, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 4), {TextTransparency = 1, BackgroundTransparency = 1})
    tween:Play()
    tween.Completed:Connect(function()
        notif:Destroy()
    end)
end

-- Brole Health Parsing --

local healthLabel = nil

-- Try to get healthLabel safely
local function tryGetHealthLabel()
    local success, result = pcall(function()
        return playerGui:WaitForChild("HUDS", 5):WaitForChild("HUD", 5):WaitForChild("Frame", 5):WaitForChild("Health", 5):WaitForChild("Container", 5):WaitForChild("Value", 5)
    end)
    if success then return result else return nil end
end

healthLabel = tryGetHealthLabel()

local function getNumbersFromText(text)
    local numbers = {}
    for num in text:gmatch("%d+%.?%d*") do
        table.insert(numbers, tonumber(num))
    end
    return numbers
end

local function getBroleHealth()
    if not healthLabel then
        healthLabel = tryGetHealthLabel()
        if not healthLabel then
            return nil, nil
        end
    end

    local rawText = healthLabel.Text
    local numbers = getNumbersFromText(rawText)

    if #numbers >= 2 then
        return numbers[1], numbers[2]
    else
        return nil, nil
    end
end

-- Server Hop Logic --

local function cleanupVisitedServers()
    local currentTime = os.time()
    for serverId, timestamp in pairs(visitedServers) do
        if currentTime - timestamp > COOLDOWN_TIME then
            visitedServers[serverId] = nil
        end
    end
end

local function getServers(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(PLACE_ID)
    if cursor then
        url = url .. "&cursor=" .. cursor
    end

    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if not success then
        warn("Failed to get server list: ", response)
        return nil, nil
    end

    local data = HttpService:JSONDecode(response)
    return data.data, data.nextPageCursor
end

local function findServerToTeleport()
    local cursor = nil
    cleanupVisitedServers()

    repeat
        local servers, nextCursor = getServers(cursor)
        if not servers or #servers == 0 then
            return nil
        end

        for _, server in ipairs(servers) do
            local id = server.id
            local playing = server.playing
            local maxPlayers = server.maxPlayers

            if playing < maxPlayers and not visitedServers[id] then
                return id
            end
        end

        cursor = nextCursor
    until not cursor

    return nil
end

local function teleportToServer()
    local serverId = findServerToTeleport()

    if serverId then
        print("Teleporting to server:", serverId)
        visitedServers[serverId] = os.time()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, serverId, player)
    else
        warn("No available servers to teleport to!")
    end
end

-- Main loop --

local function mainLoop()
    local currentHealth, maxHealth = getBroleHealth()

    if currentHealth and maxHealth then
        print(string.format("Brole's Health: %.2f / %.2f", currentHealth, maxHealth))

        if currentHealth > 0 then
            makeNotification("Brole Alive!!!", Color3.fromRGB(0, 255, 0))
            running = false
            statusLabel.Text = "🟢 BROLE ALIVE"
            toggleButton.Text = "Start Server Hop"
            return
        end
    else
        print("Could not read Brole's health")
    end

    teleportToServer()
end

-- Toggle UI update --

local function updateUI()
    if running then
        statusLabel.Text = "🟡 Server Hopping..."
        toggleButton.Text = "Stop Server Hop"
    else
        statusLabel.Text = "🔴 OFF"
        toggleButton.Text = "Start Server Hop"
    end
end

local loopCoroutine = nil

-- Start / Stop toggle --

local function toggleRunning()
    running = not running
    updateUI()
    if running then
        loopCoroutine = task.spawn(function()
            while running do
                mainLoop()
                task.wait(1)
            end
        end)
    elseif loopCoroutine then
        -- Coroutine will stop naturally on next check
        loopCoroutine = nil
    end
end

toggleButton.MouseButton1Click:Connect(toggleRunning)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        toggleRunning()
    end
end)

updateUI()
