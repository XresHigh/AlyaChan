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

-- Player
local LocalPlayer = Players.LocalPlayer

-- ESP Variables dari Xres
local survivorColor = Color3.fromRGB(0, 255, 0)
local killerBaseColor = Color3.fromRGB(255, 0, 0)
local nametagsEnabled, playerESPEnabled = false, false
local playerConns = {}
local espLoopConn = nil

-- World ESP Variables untuk Generator
local generatorColor = Color3.fromRGB(0, 170, 255)
local generatorEnabled = false
local generatorReg = {}
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

-- Player ESP Functions dari Xres
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

-- ==================== GENERATOR ESP CODE DARI XRES ====================

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
    end
    return firstBasePart(model)
end

local function ensureGeneratorEntry(model)
    if not alive(model) or generatorReg[model] then return end
    local rep = pickRep(model, "Generator")
    if not validPart(rep) then return end
    generatorReg[model] = {part = rep}
end

local function removeGeneratorEntry(model)
    local e = generatorReg[model]
    if not e then return end
    clearChild(e.part, "Xres_Generator")
    clearChild(e.part, "Xres_Text_Generator")
    generatorReg[model] = nil
end

local function registerGeneratorFromDescendant(obj)
    if not alive(obj) then return end
    
    if obj:IsA("Model") then
        local name = obj.Name:lower()
        
        -- Generator detection
        if name:find("generator") then
            ensureGeneratorEntry(obj)
        end
    end
end

local function scanWorkspaceForGenerators()
    for _, obj in pairs(Workspace:GetDescendants()) do
        registerGeneratorFromDescendant(obj)
    end
end

local function startGeneratorLoop()
    if worldLoopThread then return end
    
    worldLoopThread = task.spawn(function()
        while generatorEnabled do
            for model, entry in pairs(generatorReg) do
                if model and alive(model) and entry.part and alive(entry.part) then
                    -- Create ESP box
                    local tagName = "Xres_Generator"
                    local textName = "Xres_Text_Generator"
                    
                    local a = entry.part:FindFirstChild(tagName)
                    if not a then
                        a = Instance.new("BoxHandleAdornment")
                        a.Name = tagName
                        a.Adornee = entry.part
                        a.AlwaysOnTop = true
                        a.ZIndex = 10
                        a.Size = entry.part.Size + Vector3.new(0.2, 0.2, 0.2)
                        a.Transparency = 0.5
                        a.Color3 = generatorColor
                        a.Parent = entry.part
                    end
                    
                    -- Create text label
                    local bb = entry.part:FindFirstChild(textName) 
                    if not bb then
                        bb = makeBillboard("Generator", generatorColor)
                        bb.Name = textName
                        bb.Parent = entry.part
                    end
                else
                    removeGeneratorEntry(model)
                end
            end
            task.wait(0.3)
        end
        worldLoopThread = nil
    end)
end

local function setGeneratorToggle(state)
    generatorEnabled = state
    
    if state then
        if not worldLoopThread then 
            startGeneratorLoop() 
        end
    else
        for model, entry in pairs(generatorReg) do
            if entry and entry.part then
                clearChild(entry.part, "Xres_Generator")
                clearChild(entry.part, "Xres_Text_Generator")
            end
        end
    end
end

-- ==================== UI SETUP ====================

-- Tab utama
local MainTab = Window:CreateTab("ESP")

-- Player ESP Section
MainTab:CreateSection("Player ESP")

local ESPToggle = MainTab:CreateToggle({
    Name = "Player ESP",
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

local NameToggle = MainTab:CreateToggle({
    Name = "Name Tags",
    CurrentValue = false,
    Flag = "NameTags",
    Callback = function(Value)
        nametagsEnabled = Value
        if playerESPEnabled or nametagsEnabled then
            startESPLoop()
        else
            stopESPLoop()
        end
    end,
})

-- Generator ESP Section
MainTab:CreateSection("World ESP")

local GeneratorToggle = MainTab:CreateToggle({
    Name = "Generators",
    CurrentValue = false,
    Flag = "GeneratorESP",
    Callback = function(Value)
        setGeneratorToggle(Value)
    end
})

-- Color Pickers Section
MainTab:CreateSection("ESP Colors")

MainTab:CreateColorPicker({
    Name = "Survivor Color",
    Color = survivorColor,
    Flag = "SurvivorColor",
    Callback = function(Value)
        survivorColor = Value
    end
})

MainTab:CreateColorPicker({
    Name = "Killer Color", 
    Color = killerBaseColor,
    Flag = "KillerColor",
    Callback = function(Value)
        killerBaseColor = Value
    end
})

MainTab:CreateColorPicker({
    Name = "Generator Color",
    Color = generatorColor,
    Flag = "GeneratorColor",
    Callback = function(Value)
        generatorColor = Value
    end
})

-- Refresh Button
MainTab:CreateButton({
    Name = "Refresh Generators",
    Callback = function()
        -- Clear existing
        for model, entry in pairs(generatorReg) do
            removeGeneratorEntry(model)
        end
        
        -- Rescan
        scanWorkspaceForGenerators()
        Rayfield:Notify({
            Title = "Generator ESP",
            Content = "Generators refreshed!",
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

-- Initial generator scan
scanWorkspaceForGenerators()

-- Notifikasi ketika load
Rayfield:Notify({
    Title = "XresHub",
    Content = "ESP System Loaded with Generator ESP!",
    Duration = 3
})