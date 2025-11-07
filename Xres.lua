-- Xres Rayfield Version
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Xres | Version 1.0.0",
   LoadingTitle = "Xres.",
   LoadingSubtitle = "Version 1.0.0",
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

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
local NoShadowEnabled = false
local ServerInfoEnabled = false
local HitboxExpanderEnabled = false
local HitboxMultiplier = 1.5
local Connections = {}
local OriginalLightingSettings = {}
local OriginalShadowSettings = {}

-- ESP Variables
local survivorColor = Color3.fromRGB(0, 255, 0)
local killerBaseColor = Color3.fromRGB(255, 0, 0)
local nametagsEnabled, playerESPEnabled = false, false
local playerConns = {}
local espLoopConn = nil

-- World ESP Variables
local worldColors = {
    Generator = Color3.fromRGB(0, 170, 255),
    Hook = Color3.fromRGB(255, 0, 0),
    Gate = Color3.fromRGB(255, 225, 0),
    Window = Color3.fromRGB(255, 255, 255),
    Pallet = Color3.fromRGB(255, 140, 0),
    Pumpkin = Color3.fromRGB(255, 165, 0)
}
local worldEnabled = {
    Generator = false,
    Hook = false, 
    Gate = false,
    Window = false,
    Pallet = false,
    Pumpkin = false
}
local worldReg = {
    Generator = {},
    Hook = {},
    Gate = {},
    Window = {},
    Pallet = {},
    Pumpkin = {}
}
local worldLoopThread = nil

-- Variables untuk HUD
local ServerInfoGUI

-- Helper Functions
local function alive(obj)
    if not obj then return false end
    local success = pcall(function() return obj.Parent ~= nil end)
    return success
end

local function validPart(p) 
    return p and alive(p) and p:IsA("BasePart") 
end

local function clamp(n, lo, hi) 
    if n < lo then return lo elseif n > hi then return hi else return n end 
end

local function firstBasePart(inst)
    if not alive(inst) then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") and alive(inst.PrimaryPart) then 
            return inst.PrimaryPart 
        end
        local p = inst:FindFirstChildWhichIsA("BasePart", true)
        if validPart(p) then return p end
    end
    return nil
end

local function makeBillboard(text, color3)
    local g = Instance.new("BillboardGui")
    g.Name = "Xres_Tag"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(0, 200, 0, 36)
    g.StudsOffset = Vector3.new(0, 3, 0)
    
    local l = Instance.new("TextLabel")
    l.Name = "Label"
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 1, 0)
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextSize = 14
    l.TextColor3 = color3 or Color3.new(1,1,1)
    l.TextStrokeTransparency = 0
    l.TextStrokeColor3 = Color3.new(0,0,0)
    l.Parent = g
    return g
end

local function clearChild(o, n)
    if o and alive(o) then
        local c = o:FindFirstChild(n)
        if c then pcall(function() c:Destroy() end) end
    end
end

local function ensureHighlight(model, fill)
    if not (model and model:IsA("Model") and alive(model)) then return end
    local hl = model:FindFirstChild("Xres_HL")
    if not hl then
        local ok, obj = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "Xres_HL"
            h.Adornee = model
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = model
            return h
        end)
        if ok then hl = obj else return end
    end
    hl.FillColor = fill
    hl.OutlineColor = fill
    return hl
end

local function clearHighlight(model)
    if model and model:FindFirstChild("Xres_HL") then
        pcall(function() model.Xres_HL:Destroy() end)
    end
end

-- Player ESP Functions
local function getRole(p)
    local tn = p.Team and p.Team.Name and p.Team.Name:lower() or ""
    if tn:find("killer") then return "Killer" end
    if tn:find("survivor") then return "Survivor" end
    return "Survivor"
end

local function applyOnePlayerESP(p)
    if p == LocalPlayer then return end
    local c = p.Character
    if not (c and alive(c)) then return end
    
    local col = (getRole(p) == "Killer") and killerBaseColor or survivorColor
    
    if playerESPEnabled then
        ensureHighlight(c, col)
        local head = c:FindFirstChild("Head")
        if nametagsEnabled and validPart(head) then
            local tag = head:FindFirstChild("Xres_Tag") or makeBillboard(p.Name, col)
            tag.Name = "Xres_Tag"
            tag.Parent = head
            local l = tag:FindFirstChild("Label")
            if l then
                l.Text = p.Name
                l.TextColor3 = col
            end
        else
            local t = head and head:FindFirstChild("Xres_Tag")
            if t then pcall(function() t:Destroy() end) end
        end
    else
        clearHighlight(c)
        local head = c:FindFirstChild("Head")
        local t = head and head:FindFirstChild("Xres_Tag")
        if t then pcall(function() t:Destroy() end) end
    end
end

local function startESPLoop()
    if espLoopConn then return end
    espLoopConn = RunService.Heartbeat:Connect(function()
        if not playerESPEnabled and not nametagsEnabled then return end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then 
                applyOnePlayerESP(pl) 
            end
        end
    end)
end

local function stopESPLoop()
    if espLoopConn then 
        espLoopConn:Disconnect() 
        espLoopConn = nil 
    end
end

local function watchPlayer(p)
    if playerConns[p] then 
        for _, cn in ipairs(playerConns[p]) do 
            cn:Disconnect() 
        end 
    end
    playerConns[p] = {}
    
    table.insert(playerConns[p], p.CharacterAdded:Connect(function()
        task.delay(0.15, function() applyOnePlayerESP(p) end)
    end))
    
    table.insert(playerConns[p], p:GetPropertyChangedSignal("Team"):Connect(function() 
        applyOnePlayerESP(p) 
    end))
    
    if p.Character then 
        applyOnePlayerESP(p) 
    end
end

local function unwatchPlayer(p)
    if p.Character then
        clearHighlight(p.Character)
        local head = p.Character:FindFirstChild("Head")
        if head and head:FindFirstChild("Xres_Tag") then 
            pcall(function() head.Xres_Tag:Destroy() end) 
        end
    end
    if playerConns[p] then 
        for _, cn in ipairs(playerConns[p]) do 
            cn:Disconnect() 
        end 
    end
    playerConns[p] = nil
end

-- World ESP Functions
local function pickRep(model, cat)
    if not (model and alive(model)) then return nil end
    if cat == "Generator" then
        local hb = model:FindFirstChild("HitBox", true)
        if validPart(hb) then return hb end
    elseif cat == "Pallet" then
        local a = model:FindFirstChild("HumanoidRootPart", true) 
        if validPart(a) then return a end
        local b = model:FindFirstChild("PrimaryPartPallet", true)
        if validPart(b) then return b end
    end
    return firstBasePart(model)
end

local function genLabelData(model)
    local pct = tonumber(model:GetAttribute("RepairProgress")) or 0
    if pct >= 0 and pct <= 1.001 then pct = pct * 100 end
    pct = clamp(pct, 0, 100)
    
    local parts = {"Generator "..tostring(math.floor(pct + 0.5)).."%"}
    local text = table.concat(parts, " ")
    local hue = clamp((pct/100) * 0.33, 0, 0.33)
    local labelColor = Color3.fromHSV(hue, 1, 1)
    
    return text, labelColor
end

local function ensureWorldEntry(cat, model)
    if not alive(model) or worldReg[cat][model] then return end
    local rep = pickRep(model, cat)
    if not validPart(rep) then return end
    worldReg[cat][model] = {part = rep}
end

local function removeWorldEntry(cat, model)
    local e = worldReg[cat][model]
    if not e then return end
    clearChild(e.part, "Xres_"..cat)
    clearChild(e.part, "Xres_Text_"..cat)
    worldReg[cat][model] = nil
end

local function registerFromDescendant(obj)
    if not alive(obj) then return end
    
    if obj:IsA("Model") then
        local name = obj.Name:lower()
        if name:find("generator") then
            ensureWorldEntry("Generator", obj)
        elseif name:find("hook") then
            ensureWorldEntry("Hook", obj)
        elseif name:find("gate") or name:find("exit") then
            ensureWorldEntry("Gate", obj)
        elseif name:find("window") then
            ensureWorldEntry("Window", obj)
        elseif name:find("pallet") then
            ensureWorldEntry("Pallet", obj)
        elseif name:find("pumpkin") then
            ensureWorldEntry("Pumpkin", obj)
        end
    end
end

local function scanWorkspaceForObjects()
    for _, obj in pairs(Workspace:GetDescendants()) do
        registerFromDescendant(obj)
    end
end

local function anyWorldEnabled()
    for _, v in pairs(worldEnabled) do
        if v then return true end
    end
    return false
end

local function startWorldLoop()
    if worldLoopThread then return end
    
    worldLoopThread = task.spawn(function()
        while anyWorldEnabled() do
            for cat, models in pairs(worldReg) do
                if worldEnabled[cat] then
                    local col = worldColors[cat]
                    local tagName = "Xres_"..cat
                    local textName = "Xres_Text_"..cat
                    
                    for model, entry in pairs(models) do
                        if model and alive(model) then
                            local part = entry.part
                            if not validPart(part) or (model:IsA("Model") and not part:IsDescendantOf(model)) then
                                entry.part = pickRep(model, cat)
                                part = entry.part
                            end
                            
                            if validPart(part) then
                                -- Create/Update BoxHandleAdornment
                                local a = part:FindFirstChild(tagName)
                                if not a then
                                    local b = Instance.new("BoxHandleAdornment")
                                    b.Name = tagName
                                    b.Adornee = part
                                    b.ZIndex = 10
                                    b.AlwaysOnTop = true
                                    b.Transparency = 0.5
                                    b.Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
                                    b.Color3 = col
                                    b.Parent = part
                                else
                                    a.Color3 = col
                                    a.Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
                                end
                                
                                -- Create/Update Billboard
                                local bb = part:FindFirstChild(textName)
                                if not bb then
                                    local newbb = makeBillboard(cat, col)
                                    newbb.Name = textName
                                    newbb.Parent = part
                                    bb = newbb
                                end
                                
                                local lbl = bb:FindFirstChild("Label")
                                if lbl then
                                    if cat == "Generator" then
                                        local txt, lblCol = genLabelData(model)
                                        lbl.Text = txt
                                        lbl.TextColor3 = lblCol
                                    else
                                        lbl.Text = cat
                                        lbl.TextColor3 = col
                                    end
                                end
                            end
                        else
                            removeWorldEntry(cat, model)
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        worldLoopThread = nil
    end)
end

local function setWorldToggle(cat, state)
    worldEnabled[cat] = state
    
    if state then
        if not worldLoopThread then 
            startWorldLoop() 
        end
    else
        for _, entry in pairs(worldReg[cat]) do
            if entry and entry.part then
                clearChild(entry.part, "Xres_"..cat)
                clearChild(entry.part, "Xres_Text_"..cat)
            end
        end
    end
end

-- Main Functions
function EnableNoFog()
    OriginalFogEnd = Lighting.FogEnd
    Lighting.FogEnd = 100000
end

function DisableNoFog()
    if OriginalFogEnd then
        Lighting.FogEnd = OriginalFogEnd
    end
end

-- Versi lebih optimal untuk FPS
local NoShadowEnabled = false

function EnableNoShadow()
    -- Lighting settings
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    
    -- Disable shadows untuk character parts saja (lebih ringan)
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
            end
        end
    end
    
    -- Untuk player lain
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                end
            end
        end
    end
end

function DisableNoShadow()
    Lighting.GlobalShadows = true
    Lighting.ShadowSoftness = 0.5
    
    -- Enable shadows kembali
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = true
            end
        end
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
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"))
    end)
    
    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(placeId, randomServer)
        else
            Rayfield:Notify({
                Title = "Server Hop",
                Content = "No available servers found!",
                Duration = 3
            })
        end
    else
        Rayfield:Notify({
            Title = "Server Hop",
            Content = "Failed to fetch servers!",
            Duration = 3
        })
    end
end

-- Hitbox Expander
function EnableHitboxExpander()
    if Connections.HitboxExpander then
        Connections.HitboxExpander:Disconnect()
    end
    
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
                    part.Size = Vector3.new(1, 1, 1)
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
        FogEnd = Lighting.FogEnd
    }
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    
    if settings().Rendering then
        OriginalLightingSettings.QualityLevel = settings().Rendering.QualityLevel
        settings().Rendering.QualityLevel = 1
    end
    
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
    if OriginalLightingSettings.QualityLevel ~= nil and settings().Rendering then
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
    Connections.AntiAFK = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

function DisableAntiAFK()
    if Connections.AntiAFK then 
        Connections.AntiAFK:Disconnect() 
        Connections.AntiAFK = nil
    end
end

function EnableGodMode()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
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

-- Create Tabs
local PlayerTab = Window:CreateTab("Player")
local BoostTab = Window:CreateTab("Boost")
local UtilityTab = Window:CreateTab("Utility")
local VisualTab = Window:CreateTab("Visual")
local ESPTab = Window:CreateTab("ESP")
local WorldTab = Window:CreateTab("World")

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

PlayerTab:CreateSection("AFK")

PlayerTab:CreateToggle({
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

-- Utility Tab
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

UtilityTab:CreateSection("Server")

UtilityTab:CreateToggle({
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

UtilityTab:CreateButton({
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


-- Visual Tab
VisualTab:CreateSection("Lighting")

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
    Name = "No Shadow",
    CurrentValue = false,
    Flag = "NoShadowToggle",
    Callback = function(Value)
        NoShadowEnabled = Value
        if Value then
            EnableNoShadow()
            Rayfield:Notify({
                Title = "No Shadow",
                Content = "Shadows disabled!",
                Duration = 3
            })
        else
            DisableNoShadow()
            Rayfield:Notify({
                Title = "No Shadow", 
                Content = "Shadows enabled!",
                Duration = 3
            })
        end
    end,
})

-- ESP Tab
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Player ESP (Chams)",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        playerESPEnabled = Value
        if playerESPEnabled or nametagsEnabled then
            startESPLoop()
        else
            stopESPLoop()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Nametags",
    CurrentValue = false,
    Flag = "Nametags",
    Callback = function(Value)
        nametagsEnabled = Value
        if playerESPEnabled or nametagsEnabled then
            startESPLoop()
        else
            stopESPLoop()
        end
    end
})

ESPTab:CreateSection("Player ESP Color")

ESPTab:CreateColorPicker({
    Name = "Survivor Color",
    Color = survivorColor,
    Flag = "SurvivorCol",
    Callback = function(c) 
        survivorColor = c 
    end
})

ESPTab:CreateColorPicker({
    Name = "Killer Color",
    Color = killerBaseColor,
    Flag = "KillerCol",
    Callback = function(c) 
        killerBaseColor = c 
    end
})

-- World Tab
WorldTab:CreateSection("World ESP Toggles")

WorldTab:CreateToggle({
    Name = "Generators",
    CurrentValue = false,
    Flag = "GenESP",
    Callback = function(Value)
        setWorldToggle("Generator", Value)
    end
})

WorldTab:CreateToggle({
    Name = "Hooks", 
    CurrentValue = false,
    Flag = "HookESP",
    Callback = function(Value)
        setWorldToggle("Hook", Value)
    end
})

WorldTab:CreateToggle({
    Name = "Gates",
    CurrentValue = false,
    Flag = "GateESP",
    Callback = function(Value)
        setWorldToggle("Gate", Value)
    end
})

WorldTab:CreateToggle({
    Name = "Windows",
    CurrentValue = false,
    Flag = "WindowESP",
    Callback = function(Value)
        setWorldToggle("Window", Value)
    end
})

WorldTab:CreateToggle({
    Name = "Pallets",
    CurrentValue = false,
    Flag = "PalletESP",
    Callback = function(Value)
        setWorldToggle("Pallet", Value)
    end
})

WorldTab:CreateToggle({
    Name = "Pumpkins",
    CurrentValue = false,
    Flag = "PumpkinESP",
    Callback = function(Value)
        setWorldToggle("Pumpkin", Value)
    end
})

WorldTab:CreateSection("World ESP Colors")

WorldTab:CreateColorPicker({
    Name = "Generators Color",
    Color = worldColors.Generator,
    Flag = "GenColor",
    Callback = function(c) worldColors.Generator = c end
})

WorldTab:CreateColorPicker({
    Name = "Hooks Color",
    Color = worldColors.Hook,
    Flag = "HookColor", 
    Callback = function(c) worldColors.Hook = c end
})

WorldTab:CreateColorPicker({
    Name = "Gates Color",
    Color = worldColors.Gate,
    Flag = "GateColor",
    Callback = function(c) worldColors.Gate = c end
})

WorldTab:CreateColorPicker({
    Name = "Windows Color",
    Color = worldColors.Window,
    Flag = "WindowColor",
    Callback = function(c) worldColors.Window = c end
})

WorldTab:CreateColorPicker({
    Name = "Pallets Color",
    Color = worldColors.Pallet,
    Flag = "PalletColor",
    Callback = function(c) worldColors.Pallet = c end
})

WorldTab:CreateColorPicker({
    Name = "Pumpkins Color",
    Color = worldColors.Pumpkin,
    Flag = "PumpkinColor",
    Callback = function(c) worldColors.Pumpkin = c end
})

WorldTab:CreateButton({
    Name = "Refresh World Objects",
    Callback = function()
        -- Clear existing
        for cat, _ in pairs(worldReg) do
            for model, entry in pairs(worldReg[cat]) do
                removeWorldEntry(cat, model)
            end
        end
        
        -- Rescan
        scanWorkspaceForObjects()
        Rayfield:Notify({
            Title = "World ESP",
            Content = "World objects refreshed!",
            Duration = 3
        })
    end
})

-- Boost Tab
BoostTab:CreateToggle({
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

-- Teleport Tab
UtilityTab:CreateSection("Teleport")

local selectedPlayer = nil
local playerDropdown = UtilityTab:CreateDropdown({
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

UtilityTab:CreateButton({
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

-- Initialize ESP system
for _, p in ipairs(Players:GetPlayers()) do 
    if p ~= LocalPlayer then 
        watchPlayer(p) 
    end 
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(unwatchPlayer)

-- Initial world scan
scanWorkspaceForObjects()

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    wait(1)
    
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    wait(1)
    
    if NoShadowEnabled then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
            end
        end
    end
    
    -- Existing code...
end)

-- Auto apply ke player baru
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if NoShadowEnabled then
            wait(1)
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CastShadow = false
                end
            end
        end
    end)
end)
    
    if Humanoid then
        Humanoid.WalkSpeed = Xres.WalkSpeed
    end
    if Xres.NoClip then EnableNoClip() end
    if Xres.InfinityJump then EnableInfinityJump() end
    if Xres.AntiAFK then EnableAntiAFK() end
    if Xres.GodMode then EnableGodMode() end
end)

-- Auto God Mode
ReplicatedStorage.DescendantAdded:Connect(function(obj)
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