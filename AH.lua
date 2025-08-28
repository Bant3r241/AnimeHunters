local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()
end)

if not success then
    warn("OrionLib failed to load!")
    return
end

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- File for saving server hop toggle state
local serverHopStateFile = "serverhop_state.json"

local function saveServerHopState(enabled)
    writefile(serverHopStateFile, HttpService:JSONEncode({enabled = enabled}))
end

local function loadServerHopState()
    if isfile(serverHopStateFile) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(serverHopStateFile))
        end)
        if success and data and data.enabled then
            return true
        end
    end
    return false
end

local Window = OrionLib:MakeWindow({
    Name = "ABI │ AnimeHunters",
    HidePremium = false,
    IntroEnabled = false,
    IntroText = "ABI",
    SaveConfig = true,
    ConfigFolder = "XlurConfig"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Health label for Brole
local playerGui = player:WaitForChild("PlayerGui")
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

local function waitForHealthReady(timeout)
    timeout = timeout or 15
    local start = tick()
    while tick() - start < timeout do
        local current, max = getBroleHealth()
        if current and max and max > 0 then
            return current, max
        end
        task.wait(1)
    end
    return nil, nil
end

local function serverHop()
    saveServerHopState(true)

    local placeId = game.PlaceId
    local currentJobId = game.JobId

    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if not success or not response or not response.data then
        warn("Failed to get server list")
        return
    end

    for _, server in ipairs(response.data) do
        if server.playing < server.maxPlayers and server.id ~= currentJobId then
            print("Teleporting to server: "..server.id)
            TeleportService:TeleportToPlaceInstance(placeId, server.id, player)
            return -- teleport kicks in immediately
        end
    end

    warn("No suitable server found for hopping.")
end

MiscTab:AddToggle({
    Name = "Server Hop",
    Default = false,
    Flag = "ServerHopToggle",
    Save = true,
    Callback = function(enabled)
        if enabled then
            saveServerHopState(true)
            task.spawn(function()
                while true do
                    local current, max = waitForHealthReady()
                    if current and max then
                        print(string.format("Brole's Health: %.2f / %.2f", current, max))
                        if current > 0 then
                            print("Brole is alive! Stopping server hop.")
                            break
                        else
                            print("Brole's health is 0, hopping to another server...")
                            serverHop()
                            return
                        end
                    else
                        print("Could not read Brole's health, retrying...")
                        task.wait(2)
                    end
                end
            end)
        else
            saveServerHopState(false)
        end
    end
})

OrionLib:MakeNotification({
    Name = "ABI",
    Content = "Loading Script!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

OrionLib:Init()

-- Auto trigger toggle callback on script load if toggle saved ON
task.delay(1, function()
    if OrionLib.Flags["ServerHopToggle"] then
        print("Server Hop toggle was saved ON, triggering callback to auto start hopping...")
        local callback = MiscTab.Toggles["ServerHopToggle"].Callback
        if callback then
            callback(true)
        end
    end
end)
