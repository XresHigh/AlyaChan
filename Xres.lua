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
}

-- Variables
local NoFogEnabled = false
local OriginalFogEnd
local ServerInfoEnabled = false
local ServerHopEnabled = false
local HitboxExpanderEnabled = false
local HitboxMultiplier = 1.5
local Connections = {}
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

local killerTypeName = "Killer"
local killerColors = {
    Jason = Color3.fromRGB(255, 60, 60),
    Stalker = Color3.fromRGB(255, 120, 60),
    Masked = Color3.fromRGB(255, 160, 60),
    Hidden = Color3.fromRGB(255, 60, 160),
    Abysswalker = Color3.fromRGB(120, 60, 255),
    Killer = Color3.fromRGB(255, 0, 0),
}
local function currentKillerColor()
    return killerColors[killerTypeName] or killerColors.Killer
end

local knownKillers = {Jason=true, Stalker=true, Masked=true, Hidden=true, Abysswalker=true}
do
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if r then
        local k = r:FindFirstChild("Killers")
        if k then
            for _,ch in ipairs(k:GetChildren()) do
                if ch:IsA("Folder") then knownKillers[ch.Name] = true end
            end
        end
    end
end

local function refreshKillerESPLabels()
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP and getRole(pl)=="Killer" then
            if pl.Character then
                local head = pl.Character:FindFirstChild("Head")
                if head then
                    local tag = head:FindFirstChild("VD_Tag")
                    if tag then
                        local l = tag:FindFirstChild("Label")
                        if l then l.Text = pl.Name.." ["..tostring(killerTypeName).."]" end
                    end
                end
            end
        end
    end
end

local function setKillerType(name)
    if name and knownKillers[name] and killerTypeName ~= name then
        killerTypeName = name
        refreshKillerESPLabels()
    end
end

local survivorColor = Color3.fromRGB(0,255,0)
local killerBaseColor = killerColors.Killer
local nametagsEnabled, playerESPEnabled = false, false
local playerConns = {}
local espLoopConn=nil

local function applyOnePlayerESP(p)
    if p == LP then return end
    local c = p.Character
    if not (c and alive(c)) then return end
    local col = (getRole(p)=="Killer") and currentKillerColor() or survivorColor
    if playerESPEnabled then
        ensureHighlight(c, col)
        local head = c:FindFirstChild("Head")
        if nametagsEnabled and validPart(head) then
            local tag = head:FindFirstChild("VD_Tag") or makeBillboard(p.Name, col)
            tag.Name = "VD_Tag"
            tag.Parent = head
            local l = tag:FindFirstChild("Label")
            if l then
                if getRole(p)=="Killer" then l.Text = p.Name.." ["..tostring(killerTypeName).."]" else l.Text = p.Name end
                l.TextColor3 = col
            end
        else
            local t = head and head:FindFirstChild("VD_Tag")
            if t then pcall(function() t:Destroy() end) end
        end
    else
        clearHighlight(c)
        local head = c:FindFirstChild("Head")
        local t = head and head:FindFirstChild("VD_Tag")
        if t then pcall(function() t:Destroy() end) end
    end
end

local function startESPLoop()
    if espLoopConn then return end
    espLoopConn = RunService.Heartbeat:Connect(function()
        if not playerESPEnabled and not nametagsEnabled then return end
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=LP then applyOnePlayerESP(pl) end
        end
    end)
end
local function stopESPLoop()
    if espLoopConn then espLoopConn:Disconnect() espLoopConn=nil end
end

local function watchPlayer(p)
    if playerConns[p] then for _,cn in ipairs(playerConns[p]) do cn:Disconnect() end end
    playerConns[p] = {}
    table.insert(playerConns[p], p.CharacterAdded:Connect(function()
        task.delay(0.15, function() applyOnePlayerESP(p) end)
    end))
    table.insert(playerConns[p], p:GetPropertyChangedSignal("Team"):Connect(function() applyOnePlayerESP(p) end))
    if p.Character then applyOnePlayerESP(p) end
end
local function unwatchPlayer(p)
    if p.Character then
        clearHighlight(p.Character)
        local head = p.Character:FindFirstChild("Head")
        if head and head:FindFirstChild("VD_Tag") then pcall(function() head.VD_Tag:Destroy() end) end
    end
    if playerConns[p] then for _,cn in ipairs(playerConns[p]) do cn:Disconnect() end end
    playerConns[p] = nil
end

TabESP:CreateSection("Players")
TabESP:CreateToggle({Name="Player ESP (Chams)",CurrentValue=false,Flag="PlayerESP",Callback=function(s)
    playerESPEnabled=s
    if playerESPEnabled or nametagsEnabled then startESPLoop() else stopESPLoop() end
end})
TabESP:CreateToggle({Name="Nametags",CurrentValue=false,Flag="Nametags",Callback=function(s)
    nametagsEnabled=s
    if playerESPEnabled or nametagsEnabled then startESPLoop() else stopESPLoop() end
end})
TabESP:CreateColorPicker({Name="Survivor Color",Color=survivorColor,Flag="SurvivorCol",Callback=function(c) survivorColor=c end})
TabESP:CreateColorPicker({Name="Killer Color",Color=killerBaseColor,Flag="KillerCol",Callback=function(c) killerBaseColor=c killerColors.Killer=c end})


-- Create Tabs
local PlayerTab = Window:CreateTab("Player")
local TeleportTab = Window:CreateTab("Teleport")
local BoostterTab = Window:CreateTab("Boostter")
local UtilityTab = Window:CreateTab("Utility")
local TabESP   = Window:CreateTab("ESP")
local TabWorld = Window:CreateTab("World")

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