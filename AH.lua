local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Settings
local AutoTeleport = true
local DontTeleportTheSameNumber = true
local CopytoClipboard = false

-- GUI Setup
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "ServerHopForBroleGUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999

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

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Text = "Server Hop for Brole"
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 35)
statusLabel.BackgroundTransparency = 1
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

-- Dragging
local dragging, dragInput, dragStart, startPos

local function updatePosition(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

-- Health
local serverHopEnabled = true
local running = false

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
        return numbers[1], numbers[2]
    else
        return nil, nil
    end
end

-- Notification Sound Setup
local notificationSound = Instance.new("Sound", playerGui)
notificationSound.SoundId = "rbxassetid://3398620867" -- Your chosen notification sound
notificationSound.Volume = 0.7

local function notify(message)
    -- Remove any existing notification
    for _, child in pairs(screenGui:GetChildren()) do
        if child.Name == "BroleAliveNotification" then
            child:Destroy()
        end
    end

    -- Create background frame
    local bg = Instance.new("Frame")
    bg.Name = "BroleAliveNotification"
    bg.Size = UDim2.new(0, 400, 0, 120)
    bg.Position = UDim2.new(0.5, -200, 0.5, -60) -- Center of the screen
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- dark theme
    bg.BackgroundTransparency = 0
    bg.ZIndex = 9999
    bg.Parent = screenGui

    local bgUICorner = Instance.new("UICorner")
    bgUICorner.CornerRadius = UDim.new(0, 12)
    bgUICorner.Parent = bg

    -- Text label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 0) -- bright green
    label.Font = Enum.Font.GothamBold
    label.TextSize = 36
    label.Text = message
    label.ZIndex = 10000
    label.Parent = bg

    -- Tween to fade out background
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 4)
    TweenService:Create(bg, tweenInfo, {BackgroundTransparency = 1}):Play()

    -- Play notification sound
    notificationSound:Play()

    -- Remove after 5 seconds
    task.delay(5, function()
        if bg then
            bg:Destroy()
        end
    end)
end

-- Server Hop
local maxplayers = math.huge
local serversmaxplayer
local goodserver
local placeId = game.PlaceId
local gamelink = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"

local function serversearch()
    for _, v in pairs(HttpService:JSONDecode(game:HttpGetAsync(gamelink)).data) do
        if type(v) == "table" and maxplayers > v.playing and v.id ~= game.JobId then
            serversmaxplayer = v.maxPlayers
            maxplayers = v.playing
            goodserver = v.id
        end
    end
end

local function getservers()
    serversearch()
    local response = HttpService:JSONDecode(game:HttpGetAsync(gamelink))
    if response.nextPageCursor then
        if gamelink:find("&cursor=") then
            gamelink = gamelink:sub(1, gamelink:find("&cursor=") - 1)
        end
        gamelink = gamelink .. "&cursor=" .. response.nextPageCursor
        getservers()
    end
end

local function serverHop()
    maxplayers = math.huge
    gamelink = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    getservers()

    if CopytoClipboard and setclipboard then
        setclipboard(goodserver)
    end

    if AutoTeleport and goodserver then
        local currentPlayers = #game.Players:GetPlayers() - 1
        if DontTeleportTheSameNumber then
            if currentPlayers == maxplayers then
                warn("Same number of players, not teleporting.")
                return false
            elseif goodserver == game.JobId then
                warn("Already in the best server.")
                return false
            end
        end

        print("Teleporting to better server:", goodserver)
        TeleportService:TeleportToPlaceInstance(placeId, goodserver, player)
        return true
    end
end

-- Main Loop
local function mainLoop()
    while running do
        local current, max = getBroleHealth()
        if current and max then
            broleHealthLabel.Text = string.format("Brole's Health: %.2f / %.2f", current, max)
            if current > 0 then
                notify("BROLE'S ALIVE!!!")
                print("Brole alive. Stopping hop.")
                serverHopEnabled = false
                running = false
                updateUI()
                break
            else
                wait(2)
                serverHop()
                break
            end
        else
            broleHealthLabel.Text = "Brole's Health: N/A"
            wait(2)
            serverHop()
            break
        end
        wait(1)
    end
end

-- UI & Toggles
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
        running = true
        task.spawn(function()
            while running do
                mainLoop()
                wait(1)
            end
        end)
    else
        running = false
    end
end

toggleButton.MouseButton1Click:Connect(toggleServerHop)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        toggleServerHop()
    end
end)

-- Init
updateUI()
if serverHopEnabled then
    running = true
    task.spawn(function()
        while running do
            mainLoop()
            wait(1)
        end
    end)
end
