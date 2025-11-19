local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Xres | Version 1.0.0",
    LoadingTitle = "XresHub",
    LoadingSubtitle = "1.0.0",
    ConfigurationSaving = {Enabled = true, FolderName = "Xres_Suite", FileName = "Xres_config_v3"},
    KeySystem = false
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Config
local Xres = {
    WalkSpeed = 16,
    NoClip = false,
    GodMode = false,
    InfinityJump = false,
    AntiAFK = false
}

-- Variables
local DefaultWalkSpeed = 16
local Connections = {}

-- ESP Variables dari Xres
local survivorColor = Color3.fromRGB(0, 255, 0)
local killerBaseColor = Color3.fromRGB(255, 0, 0)
local nametagsEnabled, playerESPEnabled = false, false
local playerConns = {}
local espLoopConn = nil

-- World ESP Variables
local worldColors = {
    Generator = Color3.fromRGB(0, 170, 255),
    Hook = Color3.fromRGB(255, 0, 0),
    Window = Color3.fromRGB(255, 255, 255),
    Pallet = Color3.fromRGB(255, 140, 0)
}

local worldEnabled = {
    Generator = false,
    Hook = false,
    Window = false,
    Pallet = false
}

local worldReg = {
    Generator = {},
    Hook = {},
    Window = {},
    Pallet = {}
}
local worldLoopThread = nil

-- Helper Functions dari Xres
local function alive(obj)
    if not obj then return false end
    local success = pcall(function() return obj.Parent ~= nil end)
    return success
end

local function validPart(p) 
    return p and alive(p) and p:IsA("BasePart") 
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

-- ==================== WORLD ESP CODE DARI XRES ====================

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
        
        -- Generator detection
        if name:find("generator") then
            ensureWorldEntry("Generator", obj)
        
        -- Hook detection  
        elseif name:find("hook") then
            ensureWorldEntry("Hook", obj)
            
        -- Window detection
        elseif name:find("window") then
            ensureWorldEntry("Window", obj)
            
        -- Pallet detection
        elseif name:find("pallet") then
            ensureWorldEntry("Pallet", obj)
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
                    for model, entry in pairs(models) do
                        if model and alive(model) and entry.part and alive(entry.part) then
                            -- Create ESP box
                            local tagName = "Xres_"..cat
                            local textName = "Xres_Text_"..cat
                            
                            local a = entry.part:FindFirstChild(tagName)
                            if not a then
                                a = Instance.new("BoxHandleAdornment")
                                a.Name = tagName
                                a.Adornee = entry.part
                                a.AlwaysOnTop = true
                                a.ZIndex = 10
                                a.Size = entry.part.Size + Vector3.new(0.2, 0.2, 0.2)
                                a.Transparency = 0.5
                                a.Color3 = worldColors[cat]
                                a.Parent = entry.part
                            end
                            
                            -- Create text label
                            local bb = entry.part:FindFirstChild(textName) 
                            if not bb then
                                bb = makeBillboard(cat, worldColors[cat])
                                bb.Name = textName
                                bb.Parent = entry.part
                            end
                        else
                            removeWorldEntry(cat, model)
                        end
                    end
                end
            end
            task.wait(0.3)
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
        for model, entry in pairs(worldReg[cat]) do
            if entry and entry.part then
                clearChild(entry.part, "Xres_"..cat)
                clearChild(entry.part, "Xres_Text_"..cat)
            end
        end
    end
end

-- ==================== PLAYER FUNCTIONS ====================

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

function ResetWalkSpeed()
    Xres.WalkSpeed = DefaultWalkSpeed
    if Humanoid then
        Humanoid.WalkSpeed = DefaultWalkSpeed
    end
end

-- ==================== UI SETUP ====================

-- Player Tab
local PlayerTab = Window:CreateTab("Player")

PlayerTab:CreateSection("Movement")

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

PlayerTab:CreateButton({
    Name = "Reset Speed",
    Callback = function()
        ResetWalkSpeed()
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

-- ESP Tab
local ESPTab = Window:CreateTab("ESP")

-- Player ESP Section
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
    end,
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
    end,
})

-- World ESP Section
ESPTab:CreateSection("World ESP")

ESPTab:CreateToggle({
    Name = "Generators",
    CurrentValue = false,
    Flag = "GenESP",
    Callback = function(Value)
        setWorldToggle("Generator", Value)
    end
})

ESPTab:CreateToggle({
    Name = "Hooks", 
    CurrentValue = false,
    Flag = "HookESP",
    Callback = function(Value)
        setWorldToggle("Hook", Value)
    end
})

ESPTab:CreateToggle({
    Name = "Windows",
    CurrentValue = false,
    Flag = "WindowESP",
    Callback = function(Value)
        setWorldToggle("Window", Value)
    end
})

ESPTab:CreateToggle({
    Name = "Pallets",
    CurrentValue = false,
    Flag = "PalletESP",
    Callback = function(Value)
        setWorldToggle("Pallet", Value)
    end
})

-- Color Pickers Section
ESPTab:CreateSection("ESP Colors")

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

ESPTab:CreateColorPicker({
    Name = "Generators Color",
    Color = worldColors.Generator,
    Flag = "GenColor",
    Callback = function(c) worldColors.Generator = c end
})

ESPTab:CreateColorPicker({
    Name = "Hooks Color",
    Color = worldColors.Hook,
    Flag = "HookColor", 
    Callback = function(c) worldColors.Hook = c end
})

ESPTab:CreateColorPicker({
    Name = "Windows Color",
    Color = worldColors.Window,
    Flag = "WindowColor",
    Callback = function(c) worldColors.Window = c end
})

ESPTab:CreateColorPicker({
    Name = "Pallets Color",
    Color = worldColors.Pallet,
    Flag = "PalletColor",
    Callback = function(c) worldColors.Pallet = c end
})

-- Refresh Button
ESPTab:CreateButton({
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

-- ==================== INITIALIZE ====================

-- Initialize Player ESP system
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
    
    if Humanoid then
        Humanoid.WalkSpeed = Xres.WalkSpeed
    end
    if Xres.NoClip then EnableNoClip() end
    if Xres.InfinityJump then EnableInfinityJump() end
    if Xres.AntiAFK then EnableAntiAFK() end
end)

-- Notifikasi ketika load
Rayfield:Notify({
    Title = "Xres",
    Content = "Successfully loaded",
    Duration = 3
})