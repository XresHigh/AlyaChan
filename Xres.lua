-- Load Flux UI
local Flux = loadstring(game:HttpGet('https://raw.githubusercontent.com/1f0yt/community/main/FluxLib'))()

local Window = Flux:Window("Xres Hub", "Dead By Daylight Cheats", "v1.0.0")

-- Player Tab
local PlayerTab = Window:Tab("Player", "http://www.roblox.com/asset/?id=6034684955")

-- Movement Section
PlayerTab:Section("Movement")

local walkspeedSlider = PlayerTab:Slider("Walk Speed", "Set your walk speed", 16, 200, 16, function(value)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

local noClipToggle = PlayerTab:Toggle("No Clip", "Walk through walls", false, function(state)
    if state then
        -- No Clip code here
        print("No Clip Enabled")
    else
        print("No Clip Disabled")
    end
end)

local infJumpToggle = PlayerTab:Toggle("Infinity Jump", "Jump infinitely", false, function(state)
    if state then
        -- Infinity Jump code here
        print("Infinity Jump Enabled")
    else
        print("Infinity Jump Disabled")
    end
end)

PlayerTab:Button("Reset Speed", "Reset to default speed", function()
    walkspeedSlider:Set(16)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Teleport Section
PlayerTab:Section("Teleport")

PlayerTab:Button("Teleport to Killer", "Teleport to the killer", function()
    -- Teleport to killer code here
    print("Teleporting to Killer...")
end)

PlayerTab:Button("Teleport to Survivor", "Teleport to a survivor", function()
    -- Teleport to survivor code here
    print("Teleporting to Survivor...")
end)

-- Player Dropdown
local playersList = {}
for i, v in pairs(game.Players:GetPlayers()) do
    if v ~= game.Players.LocalPlayer then
        table.insert(playersList, v.Name)
    end
end

local playerDropdown = PlayerTab:Dropdown("Select Player", "Choose player to teleport", playersList, function(selected)
    print("Selected player: " .. selected)
end)

PlayerTab:Button("Teleport to Selected", "Teleport to selected player", function()
    local selectedPlayer = playerDropdown:Get()
    if selectedPlayer then
        print("Teleporting to: " .. selectedPlayer)
    end
end)

-- AFK Section
PlayerTab:Section("AFK")

local antiAFKToggle = PlayerTab:Toggle("Anti AFK", "Prevent being kicked for AFK", false, function(state)
    if state then
        -- Anti AFK code here
        print("Anti AFK Enabled")
    else
        print("Anti AFK Disabled")
    end
end)

-- Initialize Flux UI
Flux:Init()