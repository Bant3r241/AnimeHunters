local player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local ServerHopGUI = require(game.ServerHopGUI)  -- Require the ServerHopGUI module

-- Initialize the GUI
local screenGui, mainFrame, statusLabel, toggleButton = ServerHopGUI.createGUI(player)

-- Settings for Server Hop
local placeId = game.PlaceId
local cooldownTime = 60  -- Cooldown to prevent rejoining the same server
local serverHistory = {} -- Table to track recently joined servers
local gamelink = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"

-- Your server hop and health extraction logic goes here...

-- Main loop for toggling server hop status
local running = false

local function toggleServerHop()
    running = not running
    if running then
        statusLabel.Text = "🟢 ON"  -- Show ON when running
        toggleButton.Text = "Turn OFF"
    else
        statusLabel.Text = "🔴 OFF"  -- Show OFF when stopped
        toggleButton.Text = "Turn ON"
    end
end

toggleButton.MouseButton1Click:Connect(toggleServerHop)

-- Keybind Functionality for toggling ON/OFF with the 'F' key
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        toggleServerHop()
    end
end)

-- Your dragging functionality remains the same...
