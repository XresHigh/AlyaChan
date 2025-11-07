-- Xres Universal Script
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

-- Basic Functions
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
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    return hl
end

local function clearHighlight(model)
    if model and model:FindFirstChild("Xres_HL") then
        pcall(function() model.Xres_HL:Destroy() end)
    end
end

local Window = Rayfield:CreateWindow({
    Name = "Xres | Version 1.0.0",
    LoadingTitle = "Xres Universal",
    LoadingSubtitle = "1.0.0",
    ConfigurationSaving = {Enabled = true, FolderName = "Xres_Config", FileName = "xres_config"},
    KeySystem = false
})

local TabPlayer = Window:CreateTab("Player")
local TabESP = Window:CreateTab("ESP")
local TabWorld = Window:CreateTab("World")
local TabVisual = Window:CreateTab("Visual")
local TabMisc = Window:CreateTab("Misc")

-- Universal Team Detection
local function getRole(player)
    if player == LP then return "You" end
    
    -- Method 1: Team-based detection
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("monster") or teamName:find("hunter") or teamName:find("infected") then
            return "Enemy"
        elseif teamName:find("survivor") or teamName:find("human") or teamName:find("civilian") then
            return "Ally"
        end
    end
    
    -- Method 2: Different team than local player
    if LP.Team and player.Team and player.Team ~= LP.Team then
        return "Enemy"
    end
    
    -- Method 3: Name-based detection (fallback)
    local name = player.Name:lower()
    if name:find("killer") or name:find("monster") or name:find("zombie") then
        return "Enemy"
    end
    
    return "Ally"
end

-- Colors
local allyColor = Color3.fromRGB(0, 255, 0)
local enemyColor = Color3.fromRGB(255, 0, 0)
local neutralColor = Color3.fromRGB(255, 255, 0)

local nametagsEnabled, playerESPEnabled = false, false
local playerConns = {}
local espLoopConn = nil

local function applyOnePlayerESP(p)
    if p == LP then return end
    local c = p.Character
    if not (c and alive(c)) then return end
    
    local role = getRole(p)
    local col = role == "Enemy" and enemyColor or allyColor
    
    if playerESPEnabled then
        ensureHighlight(c, col)
        local head = c:FindFirstChild("Head")
        if nametagsEnabled and validPart(head) then
            local tag = head:FindFirstChild("Xres_Tag") or makeBillboard(p.Name .. " [" .. role .. "]", col)
            tag.Name = "Xres_Tag"
            tag.Parent = head
            local l = tag:FindFirstChild("Label")
            if l then
                l.Text = p.Name .. " [" .. role .. "]"
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
            if pl ~= LP then applyOnePlayerESP(pl) end
        end
    end)
end

local function stopESPLoop()
    if espLoopConn then espLoopConn:Disconnect() espLoopConn = nil end
end

local function watchPlayer(p)
    if playerConns[p] then for _, cn in ipairs(playerConns[p]) do cn:Disconnect() end end
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
        if head and head:FindFirstChild("Xres_Tag") then pcall(function() head.Xres_Tag:Destroy() end) end
    end
    if playerConns[p] then for _, cn in ipairs(playerConns[p]) do cn:Disconnect() end end
    playerConns[p] = nil
end

-- ESP Section
TabESP:CreateSection("Players")
TabESP:CreateToggle({
    Name = "Player ESP (Chams)",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(s)
        playerESPEnabled = s
        if playerESPEnabled or nametagsEnabled then startESPLoop() else stopESPLoop() end
    end
})

TabESP:CreateToggle({
    Name = "Nametags",
    CurrentValue = false,
    Flag = "Nametags",
    Callback = function(s)
        nametagsEnabled = s
        if playerESPEnabled or nametagsEnabled then startESPLoop() else stopESPLoop() end
    end
})

TabESP:CreateColorPicker({
    Name = "Ally Color",
    Color = allyColor,
    Flag = "AllyCol",
    Callback = function(c) allyColor = c end
})

TabESP:CreateColorPicker({
    Name = "Enemy Color", 
    Color = enemyColor,
    Flag = "EnemyCol",
    Callback = function(c) enemyColor = c end
})

-- Watch all players
for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then watchPlayer(p) end end
Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(unwatchPlayer)

-- World ESP System
local worldItems = {
    Generator = {color = Color3.fromRGB(0, 170, 255), enabled = false},
    Exit = {color = Color3.fromRGB(255, 225, 0), enabled = false},
    Objective = {color = Color3.fromRGB(255, 0, 255), enabled = false},
    Vehicle = {color = Color3.fromRGB(0, 255, 255), enabled = false},
    Weapon = {color = Color3.fromRGB(255, 165, 0), enabled = false}
}

local worldReg = {}
for name in pairs(worldItems) do
    worldReg[name] = {}
end

local function findWorldObjects()
    local found = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        
        -- Deteksi generators/objectives
        if name:find("generator") or name:find("gen") or name:find("repair") then
            table.insert(found, {obj = obj, type = "Generator"})
        
        -- Deteksi exits
        elseif name:find("exit") or name:find("gate") or name:find("escape") then
            table.insert(found, {obj = obj, type = "Exit")
        
        -- Deteksi objectives
        elseif name:find("objective") or name:find("task") or name:find("goal") then
            table.insert(found, {obj = obj, type = "Objective")
        
        -- Deteksi vehicles
        elseif name:find("vehicle") or name:find("car") or name:find("boat") then
            table.insert(found, {obj = obj, type = "Vehicle")
        
        -- Deteksi weapons
        elseif name:find("weapon") or name:find("gun") or name:find("ammo") then
            table.insert(found, {obj = obj, type = "Weapon")
        end
    end
    
    return found
end

local worldLoopThread = nil

local function startWorldLoop()
    if worldLoopThread then return end
    
    worldLoopThread = task.spawn(function()
        while true do
            local anyEnabled = false
            for _, item in pairs(worldItems) do
                if item.enabled then
                    anyEnabled = true
                    break
                end
            end
            
            if not anyEnabled then break end
            
            -- Scan for objects
            local objects = findWorldObjects()
            
            for _, data in ipairs(objects) do
                if worldItems[data.type].enabled then
                    local part = firstBasePart(data.obj)
                    if validPart(part) then
                        local tagName = "Xres_" .. data.type
                        local textName = "Xres_Text_" .. data.type
                        
                        -- Create box
                        local box = part:FindFirstChild(tagName)
                        if not box then
                            box = Instance.new("BoxHandleAdornment")
                            box.Name = tagName
                            box.Adornee = part
                            box.ZIndex = 10
                            box.AlwaysOnTop = true
                            box.Transparency = 0.5
                            box.Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
                            box.Color3 = worldItems[data.type].color
                            box.Parent = part
                        end
                        
                        -- Create text
                        local text = part:FindFirstChild(textName)
                        if not text then
                            text = makeBillboard(data.type, worldItems[data.type].color)
                            text.Name = textName
                            text.Parent = part
                        end
                    end
                end
            end
            
            task.wait(1)
        end
        worldLoopThread = nil
    end)
end

local function setWorldToggle(itemType, state)
    worldItems[itemType].enabled = state
    
    if state then
        startWorldLoop()
    else
        -- Clean up existing ESP
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                clearChild(obj, "Xres_" .. itemType)
                clearChild(obj, "Xres_Text_" .. itemType)
            end
        end
    end
end

-- World ESP Toggles
TabWorld:CreateSection("World ESP")
for name, data in pairs(worldItems) do
    TabWorld:CreateToggle({
        Name = name .. " ESP",
        CurrentValue = false,
        Flag = name .. "ESP",
        Callback = function(s) setWorldToggle(name, s) end
    })
end

TabWorld:CreateSection("Colors")
for name, data in pairs(worldItems) do
    TabWorld:CreateColorPicker({
        Name = name .. " Color",
        Color = data.color,
        Flag = name .. "Col",
        Callback = function(c) data.color = c end
    })
end

-- Visual Features
local fullbrightEnabled = false
local fbLoop

TabVisual:CreateSection("Lighting")
TabVisual:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(s)
        fullbrightEnabled = s
        if fbLoop then task.cancel(fbLoop) fbLoop = nil end
        
        if s then
            fbLoop = task.spawn(function()
                while fullbrightEnabled do
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogStart = 0
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                    task.wait(0.5)
                end
            end)
        else
            -- Restore default lighting
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

TabVisual:CreateSlider({
    Name = "Time Of Day",
    Range = {0, 24},
    Increment = 1,
    CurrentValue = Lighting.ClockTime,
    Flag = "TimeOfDay",
    Callback = function(v) Lighting.ClockTime = v end
})

-- Player Features
local speedCurrent = 16
local speedHumanoid = nil
local speedEnforced = false

local function setWalkSpeed(h, v)
    if h and h.Parent then
        pcall(function() h.WalkSpeed = v end)
    end
end

local function onCharacterAdded(char)
    local h = char:WaitForChild("Humanoid", 10) or char:FindFirstChildOfClass("Humanoid")
    if h then
        speedHumanoid = h
        if speedEnforced then
            setWalkSpeed(h, speedCurrent)
        end
    end
end

if LP.Character then onCharacterAdded(LP.Character) end
LP.CharacterAdded:Connect(onCharacterAdded)

TabPlayer:CreateSection("Movement")
TabPlayer:CreateToggle({
    Name = "Speed Lock",
    CurrentValue = false,
    Flag = "SpeedLock",
    Callback = function(s)
        speedEnforced = s
        if speedHumanoid then
            if s then
                setWalkSpeed(speedHumanoid, speedCurrent)
            else
                setWalkSpeed(speedHumanoid, 16) -- Default speed
            end
        end
    end
})

TabPlayer:CreateSlider({
    Name = "Walk Speed",
    Range = {0, 200},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        speedCurrent = v
        if speedEnforced and speedHumanoid then
            setWalkSpeed(speedHumanoid, speedCurrent)
        end
    end
})

-- Noclip
local noclipEnabled = false
local noclipConn

local function setNoclip(state)
    if state and not noclipConn then
        noclipEnabled = true
        noclipConn = RunService.Stepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    elseif not state and noclipConn then
        noclipEnabled = false
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

TabPlayer:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(s) setNoclip(s) end
})

LP.CharacterAdded:Connect(function()
    if noclipEnabled then
        task.wait(0.5)
        setNoclip(true)
    end
end)

-- Teleports
local function tpCFrame(cf)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local wasNoclip = noclipEnabled
    setNoclip(true)
    hrp.CFrame = cf
    if not wasNoclip then
        task.delay(1, function() setNoclip(false) end)
    end
end

TabPlayer:CreateSection("Teleports")
TabPlayer:CreateButton({
    Name = "Teleport to Enemy",
    Callback = function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Enemy" then
                local targetHrp = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    tpCFrame(targetHrp.CFrame * CFrame.new(0, 0, -5))
                    break
                end
            end
        end
    end
})

TabPlayer:CreateButton({
    Name = "Teleport to Ally",
    Callback = function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl) == "Ally" then
                local targetHrp = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    tpCFrame(targetHrp.CFrame * CFrame.new(0, 0, -5))
                    break
                end
            end
        end
    end
})

-- Anti-AFK
local antiAFKConn

TabPlayer:CreateSection("AFK")
TabPlayer:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(s)
        if s and not antiAFKConn then
            antiAFKConn = LP.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
        elseif not s and antiAFKConn then
            antiAFKConn:Disconnect()
            antiAFKConn = nil
        end
    end
})

-- Misc
TabMisc:CreateSection("Information")
TabMisc:CreateLabel("Xres Universal Loaded")
TabMisc:CreateLabel("Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

-- Load configuration
Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Xres Universal",
    Content = "Successfully loaded!",
    Duration = 6
})