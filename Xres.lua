-- Xres Rayfield Version
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Xres",
   LoadingTitle = "Xres.",
   LoadingSubtitle = "1.0.0",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "XresConfig",
      FileName = "Settings"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Config
local Xres = {
    WalkSpeed = 16,
    ESP = false,
    NameESP = false,
    NoClip = false,
    GodMode = false,
    InfinityJump = false,
    AntiAFK = false,
    FPSBoost = false,    
    ESPColor = Color3.fromRGB(255, 50, 50),
    NameESPColor = Color3.fromRGB(50, 255, 50)
}

-- Variables
local NoFogEnabled = false
local OriginalFogEnd
local ServerInfoEnabled = false
local ServerHopEnabled = false
local HitboxExpanderEnabled = false
local HitboxMultiplier = 1.5
local Connections = {}
local ESPHighlights = {}
local OriginalLightingSettings = {}

-- Variables untuk HUD
local ServerInfoGUI

-- Functions

-- No Fog
function EnableNoFog()
    OriginalFogEnd = Lighting.FogEnd
    Lighting.FogEnd = 100000
end

function DisableNoFog()
    if OriginalFogEnd then
        Lighting.FogEnd = OriginalFogEnd
    end
end

-- Server Info HUD
function CreateServerInfoHUD()
    if ServerInfoGUI then ServerInfoGUI:Destroy() end
    
    ServerInfoGUI = Instance.new("ScreenGui")
    ServerInfoGUI.Name = "ServerInfoHUD"
    ServerInfoGUI.Parent = CoreGui
    ServerInfoGUI.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 220, 0, 100)
    Frame.Position = UDim2.new(1, -230, 0, 10)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel = 0
    Frame.Parent = ServerInfoGUI
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 120, 60)
    Stroke.Thickness = 2
    Stroke.Parent = Frame
    
    local Labels = {}
    local serverTexts = {
        "Players: 0/0", "Server Age: 0m", 
        "Job ID: ...", "Place: ..."
    }
    
    for i, text in ipairs(serverTexts) do
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 0, 20)
        Label.Position = UDim2.new(0, 5, 0, 5 + (i-1)*23)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Frame
        Labels[i] = Label
    end
    
    Connections.ServerInfo = RunService.Heartbeat:Connect(function()
        if not ServerInfoEnabled or not ServerInfoGUI then return end
        
        -- Player Count
        local playerCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        Labels[1].Text = "Players: " .. playerCount .. "/" .. maxPlayers
        
        -- Server Age (estimated)
        Labels[2].Text = "Server Age: " .. math.random(5, 60) .. "m"
        
        -- Job ID
        Labels[3].Text = "Job ID: " .. game.JobId
        
        -- Place Name
        Labels[4].Text = "Place: " .. game.PlaceId
    end)
end

-- Server Hop
function ServerHop()
    local servers = {}
    local placeId = game.PlaceId
    
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"))
    end)
    
    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, randomServer)
        else
            Rayfield:Notify({
                Title = "Server Hop",
                Content = "No available servers found!",
                Duration = 3
            })
        end
    end
end

-- Hitbox Expander
function EnableHitboxExpander()
    Connections.HitboxExpander = RunService.Heartbeat:Connect(function()
        if not HitboxExpanderEnabled then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Size = part.Size * HitboxMultiplier
                        part.Transparency = 0.5
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

function DisableHitboxExpander()
    if Connections.HitboxExpander then
        Connections.HitboxExpander:Disconnect()
        Connections.HitboxExpander = nil
    end
    
    -- Reset hitboxes
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(1, 1, 1) -- Default size
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
    end
end

function EnableESP()
    if Connections.ESP then 
        Connections.ESP:Disconnect() 
        Connections.ESP = nil
    end
    
    -- Clear existing ESP first
    for player, highlight in pairs(ESPHighlights) do
        if highlight then highlight:Destroy() end
    end
    for player, label in pairs(NameLabels) do
        if label then label:Destroy() end
    end
    ESPHighlights = {}
    NameLabels = {}
    
    if not (Xres.ESP or Xres.NameESP) then return end
    
    Connections.ESP = RunService.Heartbeat:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                
                -- Character ESP
                if Xres.ESP then
                    if not ESPHighlights[player] then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "XresESP"
                        highlight.FillColor = Xres.ESPColor
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = player.Character
                        ESPHighlights[player] = highlight
                    end
                elseif ESPHighlights[player] then
                    ESPHighlights[player]:Destroy()
                    ESPHighlights[player] = nil
                end
                
                -- Name ESP
                if Xres.NameESP and humanoidRootPart then
                    if not NameLabels[player] then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = "XresNameESP"
                        billboard.Adornee = humanoidRootPart
                        billboard.Size = UDim2.new(0, 200, 0, 50)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        billboard.AlwaysOnTop = true
                        billboard.MaxDistance = 500
                        billboard.Parent = humanoidRootPart
                        
                        local nameLabel = Instance.new("TextLabel")
                        nameLabel.Size = UDim2.new(1, 0, 1, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Text = player.Name
                        nameLabel.TextColor3 = Xres.NameESPColor
                        nameLabel.TextSize = 18
                        nameLabel.Font = Enum.Font.GothamBold
                        nameLabel.TextStrokeTransparency = 0.5
                        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        nameLabel.Parent = billboard
                        
                        NameLabels[player] = billboard
                    end
                elseif NameLabels[player] then
                    NameLabels[player]:Destroy()
                    NameLabels[player] = nil
                end
            end
        end
    end)
end

function DisableESP()
    if Connections.ESP then 
        Connections.ESP:Disconnect() 
        Connections.ESP = nil
    end
    for player, highlight in pairs(ESPHighlights) do
        if highlight then highlight:Destroy() end
    end
    for player, label in pairs(NameLabels) do
        if label then label:Destroy() end
    end
    ESPHighlights = {}
    NameLabels = {}
end

function EnableFPSBoost()
    OriginalLightingSettings = {
        GlobalShadows = Lighting.GlobalShadows,
        QualityLevel = settings().Rendering.QualityLevel,
        FogEnd = Lighting.FogEnd
    }
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    settings().Rendering.QualityLevel = 1
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then
            effect.Enabled = false
        end
    end
end

function DisableFPSBoost()
    if OriginalLightingSettings.GlobalShadows ~= nil then
        Lighting.GlobalShadows = OriginalLightingSettings.GlobalShadows
    end
    if OriginalLightingSettings.QualityLevel ~= nil then
        settings().Rendering.QualityLevel = OriginalLightingSettings.QualityLevel
    end
    if OriginalLightingSettings.FogEnd ~= nil then
        Lighting.FogEnd = OriginalLightingSettings.FogEnd
    end
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") then
            effect.Enabled = true
        end
    end
end

function EnableNoClip()
    if Connections.NoClip then Connections.NoClip:Disconnect() end
    Connections.NoClip = RunService.Stepped:Connect(function()
        if Xres.NoClip and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function DisableNoClip()
    if Connections.NoClip then 
        Connections.NoClip:Disconnect() 
        Connections.NoClip = nil
    end
end

function EnableInfinityJump()
    if Connections.InfinityJump then Connections.InfinityJump:Disconnect() end
    Connections.InfinityJump = UserInputService.JumpRequest:Connect(function()
        if Xres.InfinityJump and Character and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function DisableInfinityJump()
    if Connections.InfinityJump then 
        Connections.InfinityJump:Disconnect() 
        Connections.InfinityJump = nil
    end
end

function EnableAntiAFK()
    if Connections.AntiAFK then Connections.AntiAFK:Disconnect() end
    Connections.AntiAFK = Players.LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

function DisableAntiAFK()
    if Connections.AntiAFK then 
        Connections.AntiAFK:Disconnect() 
        Connections.AntiAFK = nil
    end
end

function EnableGodMode()
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj.Name == "VitalityBridge" then
            obj:Destroy()
        end
    end
end

function TeleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and RootPart then
        RootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

-- Server Hop
function ServerHop()
    local servers = {}
    local placeId = game.PlaceId
    
    local success, result = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"))
    end)
    
    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, randomServer)
        else
            Rayfield:Notify({
                Title = "Server Hop",
                Content = "No available servers found!",
                Duration = 3
            })
        end
    end
end

-- Hitbox Expander
function EnableHitboxExpander()
    Connections.HitboxExpander = RunService.Heartbeat:Connect(function()
        if not HitboxExpanderEnabled then return end
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.Size = part.Size * HitboxMultiplier
                        part.Transparency = 0.5
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

function DisableHitboxExpander()
    if Connections.HitboxExpander then
        Connections.HitboxExpander:Disconnect()
        Connections.HitboxExpander = nil
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(1, 1, 1) -- Default size
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Create Tabs
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local BoostterTab = Window:CreateTab("Boostter", 4483362458)
local UtilityTab = Window:CreateTab("Utility", 4483362458)

-- Player Tab
PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Xres.WalkSpeed = Value
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Xres.NoClip = Value
        if Value then
            EnableNoClip()
        else
            DisableNoClip()
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        Xres.GodMode = Value
        if Value then
            EnableGodMode()
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Flag = "InfinityJump",
    Callback = function(Value)
        Xres.InfinityJump = Value
        if Value then
            EnableInfinityJump()
        else
            DisableInfinityJump()
        end
    end,
})

-- utility Tab
UtilityTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxExpanderToggle",
    Callback = function(Value)
        HitboxExpanderEnabled = Value
        if Value then
            EnableHitboxExpander()
            Rayfield:Notify({
                Title = "Hitbox Expander",
                Content = "Hitboxes expanded!",
                Duration = 3
            })
        else
            DisableHitboxExpander()
        end
    end,
})

UtilityTab:CreateSlider({
    Name = "Hitbox Multiplier",
    Range = {1.1, 3},
    Increment = 0.1,
    Suffix = "x Size",
    CurrentValue = 1.5,
    Flag = "HitboxMultiplier",
    Callback = function(Value)
        HitboxMultiplier = Value
    end,
})

-- Visual Tab
VisualTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFogToggle",
    Callback = function(Value)
        NoFogEnabled = Value
        if Value then
            EnableNoFog()
        else
            DisableNoFog()
        end
    end,
})

VisualTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        Xres.ESP = Value
        EnableESP()
    end,
})

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Flag = "NameESP",
    Callback = function(Value)
        Xres.NameESP = Value
        EnableESP()
    end,
})

VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "ESPColor",
    Callback = function(Value)
        Xres.ESPColor = Value
        for player, highlight in pairs(ESPHighlights) do
            if highlight then
                highlight.FillColor = Value
            end
        end
    end
})

VisualTab:CreateColorPicker({
    Name = "Name Color",
    Color = Color3.fromRGB(50, 255, 50),
    Flag = "NameESPColor",
    Callback = function(Value)
        Xres.NameESPColor = Value
        for player, billboard in pairs(NameLabels) do
            if billboard then
                local textLabel = billboard:FindFirstChildWhichIsA("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = Value
                end
            end
        end
    end
})

-- Teleport Tab
local selectedPlayer = nil
local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = {},
    CurrentOption = "",
    Flag = "PlayerDropdown",
    Callback = function(Option)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name == Option and player ~= LocalPlayer then
                selectedPlayer = player
                break
            end
        end
    end,
})

-- Update player list function
local function updatePlayerList()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    playerDropdown:Refresh(playerNames, true)
end

-- Initial update and connect to player changes
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

TeleportTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if selectedPlayer then
            local success = TeleportToPlayer(selectedPlayer)
            if success then
                Rayfield:Notify({
                    Title = "Teleport",
                    Content = "Successfully teleported to " .. selectedPlayer.Name,
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "Teleport",
                    Content = "Failed to teleport!",
                    Duration = 3
                })
            end
        else
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Please select a player first!",
                Duration = 3
            })
        end
    end,
})

-- Boostter Tab
BoostterTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        Xres.AntiAFK = Value
        if Value then
            EnableAntiAFK()
        else
            DisableAntiAFK()
        end
    end,
})

BoostterTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(Value)
        Xres.FPSBoost = Value
        if Value then
            EnableFPSBoost()
            Rayfield:Notify({
                Title = "Performance",
                Content = "FPS Boost Enabled",
                Duration = 3
            })
        else
            DisableFPSBoost()
            Rayfield:Notify({
                Title = "Performance",
                Content = "FPS Boost Disabled",
                Duration = 3
            })
        end
    end,
})

BoostterTab:CreateToggle({
    Name = "Server Info",
    CurrentValue = false,
    Flag = "ServerInfoToggle",
    Callback = function(Value)
        ServerInfoEnabled = Value
        if Value then
            CreateServerInfoHUD()
        elseif ServerInfoGUI then
            ServerInfoGUI:Destroy()
            ServerInfoGUI = nil
        end
    end,
})

BoostterTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        ServerHop()
        Rayfield:Notify({
            Title = "Server Hop",
            Content = "Searching for new server...",
            Duration = 3
        })
    end,
})

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    wait(1)
    
    if Humanoid then
        Humanoid.WalkSpeed = Xres.WalkSpeed
    end
    if Xres.ESP or Xres.NameESP then EnableESP() end
    if Xres.NoClip then EnableNoClip() end
    if Xres.InfinityJump then EnableInfinityJump() end
    if Xres.AntiAFK then EnableAntiAFK() end
    if Xres.GodMode then EnableGodMode() end
end)

-- Auto God Mode
game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(obj)
    if Xres.GodMode and obj.Name == "VitalityBridge" then
        obj:Destroy()
    end
end)

-- Initial setup
wait(1)
if Humanoid then
    Humanoid.WalkSpeed = Xres.WalkSpeed
end

Rayfield:Notify({
    Title = "Xres",
    Content = "Successfully loaded!",
    Duration = 3
})

print("✅ Xres 1.0.0 Loaded")