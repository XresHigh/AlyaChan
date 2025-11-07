local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer

local function alive(i)
    if not i then return false end
    local ok = pcall(function() return i.Parent end)
    return ok and i.Parent ~= nil
end
local function validPart(p) return p and alive(p) and p:IsA("BasePart") end
local function clamp(n,lo,hi) if n<lo then return lo elseif n>hi then return hi else return n end end
local function now() return os.clock() end
local function dist(a,b) return (a-b).Magnitude end

local function firstBasePart(inst)
    if not alive(inst) then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") and alive(inst.PrimaryPart) then return inst.PrimaryPart end
        local p = inst:FindFirstChildWhichIsA("BasePart", true)
        if validPart(p) then return p end
    end
    if inst:IsA("Tool") then
        local h = inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart")
        if validPart(h) then return h end
    end
    return nil
end

local function makeBillboard(text, color3)
    local g = Instance.new("BillboardGui")
    g.Name = "VD_Tag"
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
    local hl = model:FindFirstChild("VD_HL")
    if not hl then
        local ok, obj = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VD_HL"
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
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    return hl
end

local function clearHighlight(model)
    if model and model:FindFirstChild("VD_HL") then
        pcall(function() model.VD_HL:Destroy() end)
    end
end

local Window   = Rayfield:CreateWindow({
    Name="Violence District",
    LoadingTitle="Violence District",
    LoadingSubtitle="by jlcfg",
    ConfigurationSaving={Enabled=true,FolderName="VD_Suite",FileName="vd_config_v3"},
    KeySystem=false
})
local TabPlayer= Window:CreateTab("Player")
local TabESP   = Window:CreateTab("ESP")
local TabWorld = Window:CreateTab("World")
local TabVisual= Window:CreateTab("Visual")
local TabMisc  = Window:CreateTab("Misc")

-- ========== NEW FEATURES VARIABLES ==========
local AdvancedESP = {
    KillerRadar = {
        Enabled = false,
        ShowTerrorRadius = true,
        DistanceWarning = 30,
        RadarSize = 150
    },
    ItemESP = {
        Enabled = false,
        Medkits = true,
        Toolboxes = true,
        Keys = true,
        Flashlights = true
    }
}

local AutoSystems = {
    Healing = {
        Enabled = false,
        HealWhenSafe = true,
        Priority = "LowestHealthFirst",
        HealDistance = 10
    },
    HookRescue = {
        Enabled = false,
        RescueWhenSafe = true,
        DistractKiller = false,
        RescueDistance = 15
    }
}

local GameAnalytics = {
    MatchStats = {
        GeneratorsCompleted = 0,
        SurvivorsEscaped = 0,
        KillersStunned = 0,
        HooksSabotaged = 0,
        StartTime = os.time()
    },
    Enabled = false
}

local QualityOfLife = {
    AutoEscape = {
        Enabled = false,
        OpenWhenPowered = true,
        Priority = "NearestExit"
    },
    LoadoutManager = {
        Enabled = false,
        SaveLoadouts = true,
        AutoEquip = false,
        PresetBuilds = {}
    },
    SoundEnhancer = {
        Enabled = false,
        KillerBreathing = true,
        FootstepVolume = 1.5,
        GeneratorSounds = 2.0
    }
}

local Security = {
    AntiReport = {
        Enabled = false,
        FakeMovement = true,
        RandomizeActions = false
    },
    LagSwitch = {
        Enabled = false,
        Duration = 3,
        Cooldown = 60,
        LastUsed = 0
    }
}

-- Radar GUI
local RadarGUI = nil
local ItemHighlights = {}
local KillerLastPosition = nil
local Connections = {}

-- ========== KILLER RADAR SYSTEM ==========
function CreateKillerRadar()
    if RadarGUI then RadarGUI:Destroy() end
    
    RadarGUI = Instance.new("ScreenGui")
    RadarGUI.Name = "KillerRadar"
    RadarGUI.Parent = game:GetService("CoreGui")
    RadarGUI.ResetOnSpawn = false
    
    local RadarFrame = Instance.new("Frame")
    RadarFrame.Size = UDim2.new(0, 200, 0, 200)
    RadarFrame.Position = UDim2.new(1, -220, 1, -220)
    RadarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    RadarFrame.BackgroundTransparency = 0.3
    RadarFrame.BorderSizePixel = 0
    RadarFrame.Parent = RadarGUI
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = RadarFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 50, 50)
    Stroke.Thickness = 2
    Stroke.Parent = RadarFrame
    
    -- Radar background
    local RadarCircle = Instance.new("Frame")
    RadarCircle.Size = UDim2.new(0, 150, 0, 150)
    RadarCircle.Position = UDim2.new(0.5, -75, 0.5, -75)
    RadarCircle.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    RadarCircle.BackgroundTransparency = 0.5
    RadarCircle.BorderSizePixel = 0
    RadarCircle.Parent = RadarFrame
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = RadarCircle
    
    -- Center dot (player)
    local PlayerDot = Instance.new("Frame")
    PlayerDot.Size = UDim2.new(0, 6, 0, 6)
    PlayerDot.Position = UDim2.new(0.5, -3, 0.5, -3)
    PlayerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    PlayerDot.BorderSizePixel = 0
    PlayerDot.Parent = RadarCircle
    
    local PlayerCorner = Instance.new("UICorner")
    PlayerCorner.CornerRadius = UDim.new(1, 0)
    PlayerCorner.Parent = PlayerDot
    
    -- Killer dot
    local KillerDot = Instance.new("Frame")
    KillerDot.Size = UDim2.new(0, 8, 0, 8)
    KillerDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    KillerDot.BorderSizePixel = 0
    KillerDot.Visible = false
    KillerDot.Parent = RadarCircle
    
    local KillerCorner = Instance.new("UICorner")
    KillerCorner.CornerRadius = UDim.new(1, 0)
    KillerCorner.Parent = KillerDot
    
    -- Terror radius circle
    local TerrorCircle = Instance.new("Frame")
    TerrorCircle.Size = UDim2.new(0, 100, 0, 100)
    TerrorCircle.Position = UDim2.new(0.5, -50, 0.5, -50)
    TerrorCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    TerrorCircle.BackgroundTransparency = 0.9
    TerrorCircle.BorderSizePixel = 0
    TerrorCircle.Visible = false
    TerrorCircle.Parent = RadarCircle
    
    local TerrorCorner = Instance.new("UICorner")
    TerrorCorner.CornerRadius = UDim.new(1, 0)
    TerrorCorner.Parent = TerrorCircle
    
    return {
        Frame = RadarFrame,
        Radar = RadarCircle,
        PlayerDot = PlayerDot,
        KillerDot = KillerDot,
        TerrorCircle = TerrorCircle
    }
end

function UpdateKillerRadar()
    if not AdvancedESP.KillerRadar.Enabled or not RadarGUI then return end
    
    local playerChar = LP.Character
    local playerRoot = playerChar and playerChar:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return end
    
    local killer = nil
    local killerDistance = math.huge
    
    -- Find nearest killer
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and getRole(plr) == "Killer" then
            local killerChar = plr.Character
            local killerRoot = killerChar and killerChar:FindFirstChild("HumanoidRootPart")
            if killerRoot then
                local dist = (playerRoot.Position - killerRoot.Position).Magnitude
                if dist < killerDistance then
                    killerDistance = dist
                    killer = killerRoot
                    KillerLastPosition = killerRoot.Position
                end
            end
        end
    end
    
    local radar = RadarGUI:FindFirstChild("KillerRadar")
    if radar then
        local killerDot = radar:FindFirstChild("KillerDot")
        local terrorCircle = radar:FindFirstChild("TerrorCircle")
        
        if killer and killerDot then
            -- Calculate position on radar
            local direction = (killer.Position - playerRoot.Position) * Vector3.new(1, 0, 1)
            local maxDistance = AdvancedESP.KillerRadar.RadarSize
            local radarDistance = math.min(direction.Magnitude, maxDistance)
            
            if radarDistance <= maxDistance then
                local angle = math.atan2(direction.Z, direction.X)
                local x = math.cos(angle) * (radarDistance / maxDistance) * 75
                local y = math.sin(angle) * (radarDistance / maxDistance) * 75
                
                killerDot.Position = UDim2.new(0.5, x - 4, 0.5, y - 4)
                killerDot.Visible = true
                
                -- Update terror radius
                if terrorCircle and AdvancedESP.KillerRadar.ShowTerrorRadius then
                    terrorCircle.Visible = killerDistance <= 30
                    local scale = math.min(killerDistance / 30, 1)
                    terrorCircle.Size = UDim2.new(0, 100 * scale, 0, 100 * scale)
                    terrorCircle.Position = UDim2.new(0.5, -50 * scale, 0.5, -50 * scale)
                end
            else
                killerDot.Visible = false
                if terrorCircle then terrorCircle.Visible = false end
            end
        else
            if killerDot then killerDot.Visible = false end
            if terrorCircle then terrorCircle.Visible = false end
        end
    end
end

-- ========== ITEM ESP SYSTEM ==========
function EnableItemESP()
    if Connections.ItemESP then Connections.ItemESP:Disconnect() end
    
    -- Clear existing item highlights
    for _, highlight in pairs(ItemHighlights) do
        if highlight then highlight:Destroy() end
    end
    ItemHighlights = {}
    
    Connections.ItemESP = RunService.Heartbeat:Connect(function()
        if not AdvancedESP.ItemESP.Enabled then return end
        
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local itemName = obj.Name:lower()
                local shouldHighlight = false
                local highlightColor = Color3.fromRGB(255, 255, 255)
                
                -- Check item types
                if AdvancedESP.ItemESP.Medkits and itemName:find("medkit") then
                    shouldHighlight = true
                    highlightColor = Color3.fromRGB(255, 50, 50) -- Red
                elseif AdvancedESP.ItemESP.Toolboxes and itemName:find("toolbox") then
                    shouldHighlight = true
                    highlightColor = Color3.fromRGB(50, 150, 255) -- Blue
                elseif AdvancedESP.ItemESP.Keys and itemName:find("key") then
                    shouldHighlight = true
                    highlightColor = Color3.fromRGB(255, 255, 50) -- Yellow
                elseif AdvancedESP.ItemESP.Flashlights and itemName:find("flashlight") then
                    shouldHighlight = true
                    highlightColor = Color3.fromRGB(255, 255, 255) -- White
                end
                
                if shouldHighlight and not ItemHighlights[obj] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = highlightColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                    highlight.Parent = obj
                    ItemHighlights[obj] = highlight
                elseif not shouldHighlight and ItemHighlights[obj] then
                    ItemHighlights[obj]:Destroy()
                    ItemHighlights[obj] = nil
                end
            end
        end
    end)
end

function DisableItemESP()
    if Connections.ItemESP then
        Connections.ItemESP:Disconnect()
        Connections.ItemESP = nil
    end
    
    for _, highlight in pairs(ItemHighlights) do
        if highlight then highlight:Destroy() end
    end
    ItemHighlights = {}
end

-- ========== AUTO HEALING SYSTEM ==========
function EnableAutoHealing()
    if Connections.AutoHeal then Connections.AutoHeal:Disconnect() end
    
    Connections.AutoHeal = RunService.Heartbeat:Connect(function()
        if not AutoSystems.Healing.Enabled then return end
        
        local playerChar = LP.Character
        local humanoid = playerChar and playerChar:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health >= humanoid.MaxHealth then return end
        
        -- Check if safe to heal (no killer nearby)
        if AutoSystems.Healing.HealWhenSafe then
            local killerNearby = false
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and getRole(plr) == "Killer" then
                    local killerChar = plr.Character
                    local killerRoot = killerChar and killerChar:FindFirstChild("HumanoidRootPart")
                    local playerRoot = playerChar:FindFirstChild("HumanoidRootPart")
                    
                    if killerRoot and playerRoot then
                        local distance = (killerRoot.Position - playerRoot.Position).Magnitude
                        if distance < 20 then
                            killerNearby = true
                            break
                        end
                    end
                end
            end
            
            if killerNearby then return end
        end
        
        -- Try to find medkit and use it
        local backpack = LP:FindFirstChild("Backpack")
        local playerGui = LP:FindFirstChild("PlayerGui")
        
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("medkit") then
                    -- Equip and use medkit
                    tool.Parent = playerChar
                    -- Simulate use (this would need game-specific implementation)
                    task.wait(1)
                    tool.Parent = backpack
                    break
                end
            end
        end
    end)
end

-- ========== LAG SWITCH ==========
function ActivateLagSwitch()
    if os.time() - Security.LagSwitch.LastUsed < Security.LagSwitch.Cooldown then
        Rayfield:Notify({
            Title = "Lag Switch",
            Content = "Cooldown active! Wait " .. (Security.LagSwitch.Cooldown - (os.time() - Security.LagSwitch.LastUsed)) .. " seconds",
            Duration = 3
        })
        return
    end
    
    Security.LagSwitch.LastUsed = os.time()
    
    -- Simulate network lag (this is a basic implementation)
    local originalNetworkOwner = nil
    local playerRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    
    if playerRoot then
        originalNetworkOwner = playerRoot:GetNetworkOwner()
        playerRoot:SetNetworkOwner(nil)
    end
    
    Rayfield:Notify({
        Title = "Lag Switch",
        Content = "Activated for " .. Security.LagSwitch.Duration .. " seconds",
        Duration = 3
    })
    
    -- Restore after duration
    delay(Security.LagSwitch.Duration, function()
        if playerRoot and originalNetworkOwner then
            playerRoot:SetNetworkOwner(originalNetworkOwner)
        end
        Rayfield:Notify({
            Title = "Lag Switch",
            Content = "Deactivated",
            Duration = 3
        })
    end)
end

local function getRole(p)
    local tn = p.Team and p.Team.Name and p.Team.Name:lower() or ""
    if tn:find("killer") then return "Killer" end
    if tn:find("survivor") then return "Survivor" end
    return "Survivor"
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

-- ========== ADVANCED ESP TAB ==========
local TabAdvanced = Window:CreateTab("Advanced ESP")

TabAdvanced:CreateSection("Killer Radar")

TabAdvanced:CreateToggle({
    Name = "Killer Radar",
    CurrentValue = false,
    Flag = "KillerRadar",
    Callback = function(Value)
        AdvancedESP.KillerRadar.Enabled = Value
        if Value then
            CreateKillerRadar()
            if not Connections.KillerRadar then
                Connections.KillerRadar = RunService.Heartbeat:Connect(UpdateKillerRadar)
            end
        elseif RadarGUI then
            RadarGUI:Destroy()
            RadarGUI = nil
            if Connections.KillerRadar then
                Connections.KillerRadar:Disconnect()
                Connections.KillerRadar = nil
            end
        end
    end
})

TabAdvanced:CreateToggle({
    Name = "Show Terror Radius",
    CurrentValue = true,
    Flag = "ShowTerrorRadius",
    Callback = function(Value)
        AdvancedESP.KillerRadar.ShowTerrorRadius = Value
    end
})

TabAdvanced:CreateSlider({
    Name = "Radar Range",
    Range = {50, 300},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 150,
    Flag = "RadarRange",
    Callback = function(Value)
        AdvancedESP.KillerRadar.RadarSize = Value
    end
})

TabAdvanced:CreateSection("Item ESP")

TabAdvanced:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(Value)
        AdvancedESP.ItemESP.Enabled = Value
        if Value then
            EnableItemESP()
        else
            DisableItemESP()
        end
    end
})

TabAdvanced:CreateToggle({
    Name = "Medkits",
    CurrentValue = true,
    Flag = "MedkitESP",
    Callback = function(Value)
        AdvancedESP.ItemESP.Medkits = Value
    end
})

TabAdvanced:CreateToggle({
    Name = "Toolboxes",
    CurrentValue = true,
    Flag = "ToolboxESP",
    Callback = function(Value)
        AdvancedESP.ItemESP.Toolboxes = Value
    end
})

TabAdvanced:CreateToggle({
    Name = "Keys",
    CurrentValue = true,
    Flag = "KeyESP",
    Callback = function(Value)
        AdvancedESP.ItemESP.Keys = Value
    end
})

TabAdvanced:CreateToggle({
    Name = "Flashlights",
    CurrentValue = true,
    Flag = "FlashlightESP",
    Callback = function(Value)
        AdvancedESP.ItemESP.Flashlights = Value
    end
})

-- ========== AUTO SYSTEMS TAB ==========
local TabAuto = Window:CreateTab("Auto Systems")

TabAuto:CreateSection("Auto Healing")

TabAuto:CreateToggle({
    Name = "Auto Healing",
    CurrentValue = false,
    Flag = "AutoHeal",
    Callback = function(Value)
        AutoSystems.Healing.Enabled = Value
        if Value then
            EnableAutoHealing()
        elseif Connections.AutoHeal then
            Connections.AutoHeal:Disconnect()
            Connections.AutoHeal = nil
        end
    end
})

TabAuto:CreateToggle({
    Name = "Heal When Safe",
    CurrentValue = true,
    Flag = "HealWhenSafe",
    Callback = function(Value)
        AutoSystems.Healing.HealWhenSafe = Value
    end
})

TabAuto:CreateSlider({
    Name = "Heal Distance",
    Range = {5, 20},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 10,
    Flag = "HealDistance",
    Callback = function(Value)
        AutoSystems.Healing.HealDistance = Value
    end
})

TabAuto:CreateSection("Hook Rescue")

TabAuto:CreateToggle({
    Name = "Auto Hook Rescue",
    CurrentValue = false,
    Flag = "AutoHookRescue",
    Callback = function(Value)
        AutoSystems.HookRescue.Enabled = Value
        -- Implementation would go here
    end
})

-- ========== SECURITY TAB ==========
local TabSecurity = Window:CreateTab("Security")

TabSecurity:CreateSection("Lag Switch")

TabSecurity:CreateButton({
    Name = "Activate Lag Switch",
    Callback = function()
        ActivateLagSwitch()
    end
})

TabSecurity:CreateSlider({
    Name = "Lag Duration",
    Range = {1, 10},
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = 3,
    Flag = "LagDuration",
    Callback = function(Value)
        Security.LagSwitch.Duration = Value
    end
})

TabSecurity:CreateSlider({
    Name = "Cooldown",
    Range = {30, 120},
    Increment = 10,
    Suffix = "seconds",
    CurrentValue = 60,
    Flag = "LagCooldown",
    Callback = function(Value)
        Security.LagSwitch.Cooldown = Value
    end
})

TabSecurity:CreateSection("Anti-Report")

TabSecurity:CreateToggle({
    Name = "Anti-Report System",
    CurrentValue = false,
    Flag = "AntiReport",
    Callback = function(Value)
        Security.AntiReport.Enabled = Value
    end
})

TabSecurity:CreateToggle({
    Name = "Fake Movement",
    CurrentValue = true,
    Flag = "FakeMovement",
    Callback = function(Value)
        Security.AntiReport.FakeMovement = Value
    end
})

-- ========== ANALYTICS TAB ==========
local TabAnalytics = Window:CreateTab("Analytics")

TabAnalytics:CreateSection("Match Statistics")

TabAnalytics:CreateToggle({
    Name = "Enable Analytics",
    CurrentValue = false,
    Flag = "EnableAnalytics",
    Callback = function(Value)
        GameAnalytics.Enabled = Value
    end
})

TabAnalytics:CreateButton({
    Name = "Show Current Stats",
    Callback = function()
        Rayfield:Notify({
            Title = "Match Statistics",
            Content = string.format("Gens: %d | Escapes: %d | Stuns: %d | Hooks: %d",
                GameAnalytics.MatchStats.GeneratorsCompleted,
                GameAnalytics.MatchStats.SurvivorsEscaped,
                GameAnalytics.MatchStats.KillersStunned,
                GameAnalytics.MatchStats.HooksSabotaged),
            Duration = 6
        })
    end
})

TabAnalytics:CreateButton({
    Name = "Reset Statistics",
    Callback = function()
        GameAnalytics.MatchStats = {
            GeneratorsCompleted = 0,
            SurvivorsEscaped = 0,
            KillersStunned = 0,
            HooksSabotaged = 0,
            StartTime = os.time()
        }
        Rayfield:Notify({
            Title = "Analytics",
            Content = "Statistics reset!",
            Duration = 3
        })
    end
})

for _,p in ipairs(Players:GetPlayers()) do if p~=LP then watchPlayer(p) end end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(unwatchPlayer)

local worldColors = {
    Generator = Color3.fromRGB(0,170,255),
    Hook = Color3.fromRGB(255,0,0),
    Gate = Color3.fromRGB(255,225,0),
    Window = Color3.fromRGB(255,255,255),
    Palletwrong = Color3.fromRGB(255,140,0),
    Pumpkin = Color3.fromRGB(255,165,0)
}
local worldEnabled = {Generator=false,Hook=false,Gate=false,Window=false,Palletwrong=false,Pumpkin=false}
local validCats = {Generator=true,Hook=true,Gate=true,Window=true,Palletwrong=true,Pumpkin=true}
local worldReg = {Generator={},Hook={},Gate={},Window={},Palletwrong={},Pumpkin={}}
local mapAdd, mapRem = {}, {}

local palletState = setmetatable({}, {__mode="k"})
local windowState = setmetatable({}, {__mode="k"})
local function labelForPallet(model)
    local st=palletState[model] or "UP"
    if st=="DOWN" then return "Pallet (down)" end
    if st=="DEST" then return "Pallet (destroyed)" end
    if st=="SLIDE" then return "Pallet (slide)" end
    return "Pallet"
end
local function labelForWindow(model)
    local st=windowState[model] or "READY"
    return st=="BUSY" and "Window (busy)" or "Window"
end

local function pickRep(model, cat)
    if not (model and alive(model)) then return nil end
    if cat == "Generator" then
        local hb = model:FindFirstChild("HitBox", true)
        if validPart(hb) then return hb end
    elseif cat == "Palletwrong" then
        local a = model:FindFirstChild("HumanoidRootPart", true); if validPart(a) then return a end
        local b = model:FindFirstChild("PrimaryPartPallet", true); if validPart(b) then return b end
        local c = model:FindFirstChild("Primary1", true); if validPart(c) then return c end
        local d = model:FindFirstChild("Primary2", true); if validPart(d) then return d end
    elseif cat == "Pumpkin" then
        local p = model:FindFirstChildWhichIsA("BasePart", true)
        if validPart(p) then return p end
    end
    return firstBasePart(model)
end

local function genLabelData(model)
    local pct = tonumber(model:GetAttribute("RepairProgress")) or 0
    if pct>=0 and pct<=1.001 then pct = pct*100 end
    pct = clamp(pct,0,100)
    local repairers = tonumber(model:GetAttribute("PlayersRepairingCount")) or 0
    local paused = (model:GetAttribute("ProgressPaused")==true)
    local kickcount = tonumber(model:GetAttribute("kickcount")) or 0
    local abyss50 = (model:GetAttribute("Abyss50Triggered")==true)
    local parts = {"Gen "..tostring(math.floor(pct+0.5)).."%" }
    if repairers>0 then parts[#parts+1]="("..repairers.."p)" end
    if paused then parts[#parts+1]="⏸" end
    if abyss50 then parts[#parts+1]="⚠" end
    if kickcount and kickcount>0 then parts[#parts+1]="K:"..kickcount end
    local text = table.concat(parts," ")
    local hue = clamp((pct/100)*0.33,0,0.33)
    local labelColor = Color3.fromHSV(hue,1,1)
    return text, labelColor
end

local function hasAnyBasePart(m)
    if not (m and alive(m)) then return false end
    local bp = m:FindFirstChildWhichIsA("BasePart", true)
    return bp ~= nil
end

local function isPalletGone(m)
    if not alive(m) then return true end
    if not m:IsDescendantOf(Workspace) then return true end
    if palletState[m]=="DEST" then return true end
    local ok, val = pcall(function() return m:GetAttribute("Destroyed") end)
    if ok and val == true then return true end
    if not hasAnyBasePart(m) then return true end
    return false
end

local function ensureWorldEntry(cat, model)
    if not alive(model) or worldReg[cat][model] then return end
    if cat=="Palletwrong" and isPalletGone(model) then return end
    local rep = pickRep(model, cat)
    if not validPart(rep) then return end
    worldReg[cat][model] = {part = rep}
end
local function removeWorldEntry(cat, model)
    local e = worldReg[cat][model]
    if not e then return end
    clearChild(e.part, "VD_"..cat)
    clearChild(e.part, "VD_Text_"..cat)
    worldReg[cat][model] = nil
end

local function isPumpkinModelName(n)
    if not n then return false end
    return string.find(n, "^Pumpkin%d*$") ~= nil
end

local function registerFromDescendant(obj)
    if not alive(obj) then return end
    if obj:IsA("Model") then
        if validCats[obj.Name] then
            ensureWorldEntry(obj.Name, obj)
            return
        end
        if isPumpkinModelName(obj.Name) then
            ensureWorldEntry("Pumpkin", obj)
            return
        end
    end
    if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") then
        if validCats[obj.Parent.Name] then
            ensureWorldEntry(obj.Parent.Name, obj.Parent)
            return
        end
        if isPumpkinModelName(obj.Parent.Name) then
            ensureWorldEntry("Pumpkin", obj.Parent)
            return
        end
    end
end
local function unregisterFromDescendant(obj)
    if not obj then return end
    if obj:IsA("Model") then
        if validCats[obj.Name] then
            removeWorldEntry(obj.Name, obj)
            return
        end
        if isPumpkinModelName(obj.Name) then
            removeWorldEntry("Pumpkin", obj)
            return
        end
    end
    if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") then
        if validCats[obj.Parent.Name] then
            local e = worldReg[obj.Parent.Name][obj.Parent]
            if e and e.part == obj then removeWorldEntry(obj.Parent.Name, obj.Parent) end
            return
        end
        if isPumpkinModelName(obj.Parent.Name) then
            local e = worldReg.Pumpkin[obj.Parent]
            if e and e.part == obj then removeWorldEntry("Pumpkin", obj.Parent) end
            return
        end
    end
end
local function attachRoot(root)
    if not root or mapAdd[root] then return end
    mapAdd[root] = root.DescendantAdded:Connect(registerFromDescendant)
    mapRem[root] = root.DescendantRemoving:Connect(unregisterFromDescendant)
    for _,d in ipairs(root:GetDescendants()) do registerFromDescendant(d) end
end
local function refreshRoots()
    for _,cn in pairs(mapAdd) do if cn then cn:Disconnect() end end
    for _,cn in pairs(mapRem) do if cn then cn:Disconnect() end end
    mapAdd, mapRem = {}, {}
    local r1 = Workspace:FindFirstChild("Map")
    local r2 = Workspace:FindFirstChild("Map1")
    if r1 then attachRoot(r1) end
    if r2 then attachRoot(r2) end
end
refreshRoots()
Workspace.ChildAdded:Connect(function(ch) if ch.Name=="Map" or ch.Name=="Map1" then attachRoot(ch) end end)

local worldLoopThread=nil
local function anyWorldEnabled() for _,v in pairs(worldEnabled) do if v then return true end end return false end
local function startWorldLoop()
    if worldLoopThread then return end
    worldLoopThread = task.spawn(function()
        while anyWorldEnabled() do
            for cat,models in pairs(worldReg) do
                if worldEnabled[cat] then
                    local col, tagName, textName = worldColors[cat], "VD_"..cat, "VD_Text_"..cat
                    local n = 0
                    for model,entry in pairs(models) do
                        if cat=="Palletwrong" and isPalletGone(model) then
                            removeWorldEntry(cat, model)
                        else
                            local part = entry.part
                            if model and alive(model) then
                                if not validPart(part) or (model:IsA("Model") and not part:IsDescendantOf(model)) then
                                    entry.part = pickRep(model, cat); part = entry.part
                                end
                                if validPart(part) then
                                    local a = part:FindFirstChild(tagName)
                                    if not a then
                                        local b = Instance.new("BoxHandleAdornment")
                                        b.Name = tagName
                                        b.Adornee = part
                                        b.ZIndex = 10
                                        b.AlwaysOnTop = true
                                        b.Transparency = 0.5
                                        b.Size = part.Size + Vector3.new(0.2,0.2,0.2)
                                        b.Color3 = col
                                        b.Parent = part
                                    else
                                        a.Color3 = col
                                        a.Size = part.Size + Vector3.new(0.2,0.2,0.2)
                                    end
                                    local bb = part:FindFirstChild(textName)
                                    if not bb then
                                        local newbb = makeBillboard((cat=="Palletwrong" and "Pallet") or cat, col)
                                        newbb.Name = textName
                                        newbb.Parent = part
                                        bb = newbb
                                    end
                                    local lbl = bb:FindFirstChild("Label")
                                    if lbl then
                                        if cat=="Generator" then local txt,lblCol=genLabelData(model) lbl.Text=txt lbl.TextColor3=lblCol
                                        elseif cat=="Palletwrong" then lbl.Text=labelForPallet(model) lbl.TextColor3=col
                                        elseif cat=="Window" then lbl.Text=labelForWindow(model) lbl.TextColor3=col
                                        elseif cat=="Pumpkin" then lbl.Text="Pumpkin" lbl.TextColor3=col
                                        else lbl.Text=cat lbl.TextColor3=col end
                                    end
                                end
                            else
                                removeWorldEntry(cat, model)
                            end
                        end
                        n = n + 1
                        if n % 60 == 0 then task.wait() end
                    end
                end
            end
            task.wait(0.25)
        end
        worldLoopThread=nil
    end)
end
local function setWorldToggle(cat, state)
    worldEnabled[cat] = state
    if state then
        if not worldLoopThread then startWorldLoop() end
    else
        for _,entry in pairs(worldReg[cat]) do
            if entry and entry.part then
                clearChild(entry.part,"VD_"..cat); clearChild(entry.part,"VD_Text_"..cat)
            end
        end
    end
end

TabWorld:CreateSection("Toggles")
TabWorld:CreateToggle({Name="Generators",CurrentValue=false,Flag="Gen",Callback=function(s) setWorldToggle("Generator", s) end})
TabWorld:CreateToggle({Name="Hooks",CurrentValue=false,Flag="Hook",Callback=function(s) setWorldToggle("Hook", s) end})
TabWorld:CreateToggle({Name="Gates",CurrentValue=false,Flag="Gate",Callback=function(s) setWorldToggle("Gate", s) end})
TabWorld:CreateToggle({Name="Windows (Usability)",CurrentValue=false,Flag="Window",Callback=function(s) setWorldToggle("Window", s) end})
TabWorld:CreateToggle({Name="Pallets (Usability)",CurrentValue=false,Flag="Pallet",Callback=function(s) setWorldToggle("Palletwrong", s) end})
TabWorld:CreateToggle({Name="Pumpkins",CurrentValue=false,Flag="Pumpkin",Callback=function(s) setWorldToggle("Pumpkin", s) end})

TabWorld:CreateSection("Colors")
TabWorld:CreateColorPicker({Name="Generators",Color=worldColors.Generator,Flag="GenCol",Callback=function(c) worldColors.Generator=c end})
TabWorld:CreateColorPicker({Name="Hooks",Color=worldColors.Hook,Flag="HookCol",Callback=function(c) worldColors.Hook=c end})
TabWorld:CreateColorPicker({Name="Gates",Color=worldColors.Gate,Flag="GateCol",Callback=function(c) worldColors.Gate=c end})
TabWorld:CreateColorPicker({Name="Windows",Color=worldColors.Window,Flag="WinCol",Callback=function(c) worldColors.Window=c end})
TabWorld:CreateColorPicker({Name="Pallets",Color=worldColors.Palletwrong,Flag="PalCol",Callback=function(c) worldColors.Palletwrong=c end})
TabWorld:CreateColorPicker({Name="Pumpkins",Color=worldColors.Pumpkin,Flag="PumpCol",Callback=function(c) worldColors.Pumpkin=c end})

-- Add character respawn handler for new features
LP.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    
    -- Reset advanced systems
    if AdvancedESP.KillerRadar.Enabled and RadarGUI then
        CreateKillerRadar()
    end
    
    if AdvancedESP.ItemESP.Enabled then
        EnableItemESP()
    end
    
    if AutoSystems.Healing.Enabled then
        EnableAutoHealing()
    end
end)

Rayfield:LoadConfiguration()
Rayfield:Notify({Title="Violence District",Content="Enhanced Version Loaded!",Duration=6})