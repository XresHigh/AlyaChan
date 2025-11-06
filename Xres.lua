-- Xres - Premium Script Hub
if _G.XresLoaded then return end
_G.XresLoaded = true

print("🎯 Xres 1.0.0 Loading...")

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
    
    -- ESP Colors
    ESPColor = Color3.fromRGB(255, 50, 50),
    NameESPColor = Color3.fromRGB(50, 255, 50),
    ESPFillTransparency = 0.5,
    ESPOutlineTransparency = 0
}

-- Variables
local Connections = {}
local ESPHighlights = {}
local NameLabels = {}
local OriginalLightingSettings = {}

-- Functions
function EnableESP()
    if Connections.ESP then Connections.ESP:Disconnect() end
    Connections.ESP = RunService.Heartbeat:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                
                -- Character ESP
                if Xres.ESP and not ESPHighlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Xres.ESPColor
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = Xres.ESPFillTransparency
                    highlight.OutlineTransparency = Xres.ESPOutlineTransparency
                    highlight.Parent = player.Character
                    ESPHighlights[player] = highlight
                elseif not Xres.ESP and ESPHighlights[player] then
                    ESPHighlights[player]:Destroy()
                    ESPHighlights[player] = nil
                end
                
                -- Name ESP
                if Xres.NameESP and humanoidRootPart and not NameLabels[player] then
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
                elseif not Xres.NameESP and NameLabels[player] then
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
        if highlight then
            highlight:Destroy()
        end
    end
    for player, label in pairs(NameLabels) do
        if label then
            label:Destroy()
        end
    end
    ESPHighlights = {}
    NameLabels = {}
end

function EnableFPSBoost()
    -- Save original settings
    OriginalLightingSettings = {
        GlobalShadows = Lighting.GlobalShadows,
        QualityLevel = settings().Rendering.QualityLevel,
        FogEnd = Lighting.FogEnd
    }
    
    -- Apply FPS boost settings
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    settings().Rendering.QualityLevel = 1
    
    -- Disable other graphics effects
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
            effect.Enabled = false
        end
    end
end

function DisableFPSBoost()
    -- Restore original settings
    if OriginalLightingSettings.GlobalShadows ~= nil then
        Lighting.GlobalShadows = OriginalLightingSettings.GlobalShadows
    end
    if OriginalLightingSettings.QualityLevel ~= nil then
        settings().Rendering.QualityLevel = OriginalLightingSettings.QualityLevel
    end
    if OriginalLightingSettings.FogEnd ~= nil then
        Lighting.FogEnd = OriginalLightingSettings.FogEnd
    end
    
    -- Re-enable graphics effects
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
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

-- Color Picker Function
function CreateColorPicker(initialColor, callback, parent)
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0, 30, 0, 30)
    colorFrame.BackgroundColor3 = initialColor
    colorFrame.BorderSizePixel = 2
    colorFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    colorFrame.Parent = parent
    
    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 6)
    colorCorner.Parent = colorFrame
    
    colorFrame.MouseButton1Click:Connect(function()
        -- Remove any existing input
        local existingInput = colorFrame:FindFirstChild("ColorInput")
        if existingInput then
            existingInput:Destroy()
        end
        
        local colorInput = Instance.new("TextBox")
        colorInput.Name = "ColorInput"
        colorInput.Size = UDim2.new(0, 100, 0, 30)
        colorInput.Position = UDim2.new(1, 5, 0, 0)
        colorInput.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
        colorInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        colorInput.PlaceholderText = "RGB: 255,50,50"
        colorInput.Text = math.floor(initialColor.R * 255) .. "," .. math.floor(initialColor.G * 255) .. "," .. math.floor(initialColor.B * 255)
        colorInput.TextSize = 12
        colorInput.Font = Enum.Font.Gotham
        colorInput.Parent = colorFrame
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = colorInput
        
        colorInput.Focused:Connect(function()
            colorInput.Text = ""
        end)
        
        colorInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local r, g, b = colorInput.Text:match("(%d+),%s*(%d+),%s*(%d+)")
                if r and g and b then
                    r = math.clamp(tonumber(r), 0, 255)
                    g = math.clamp(tonumber(g), 0, 255)
                    b = math.clamp(tonumber(b), 0, 255)
                    
                    local newColor = Color3.fromRGB(r, g, b)
                    colorFrame.BackgroundColor3 = newColor
                    callback(newColor)
                end
            end
            wait(0.1)
            if colorInput then
                colorInput:Destroy()
            end
        end)
    end)
    
    return colorFrame
end

-- Premium UI
local MainWindow, TitleBar, ContentFrame
local IsUIVisible = true
local CurrentTab = "Player"

function CreateXresUI()
    if CoreGui:FindFirstChild("XresUI") then
        CoreGui:FindFirstChild("XresUI"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XresUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Main Window
    MainWindow = Instance.new("Frame")
    MainWindow.Size = UDim2.new(0, 400, 0, 500)
    MainWindow.Position = UDim2.new(0, 30, 0, 30)
    MainWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.Parent = ScreenGui

    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 14)
    WindowCorner.Parent = MainWindow

    local WindowStroke = Instance.new("UIStroke")
    WindowStroke.Color = Color3.fromRGB(60, 120, 255)
    WindowStroke.Thickness = 2
    WindowStroke.Parent = MainWindow

    -- Glass Effect
    local GlassFrame = Instance.new("Frame")
    GlassFrame.Size = UDim2.new(1, 0, 1, 0)
    GlassFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    GlassFrame.BackgroundTransparency = 0.1
    GlassFrame.BorderSizePixel = 0
    GlassFrame.Parent = MainWindow

    local GlassCorner = Instance.new("UICorner")
    GlassCorner.CornerRadius = UDim.new(0, 14)
    GlassCorner.Parent = GlassFrame

    -- Title Bar
    TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 14)
    TitleBarCorner.Parent = TitleBar

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 120, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Xres | Version 1.0.0"
    Title.TextColor3 = Color3.fromRGB(100, 180, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Controls
    local CloseButton = CreateControlButton("×", Color3.fromRGB(255, 80, 80), UDim2.new(1, -20, 0.5, -10), TitleBar)
    local HideButton = CreateControlButton("−", Color3.fromRGB(255, 180, 60), UDim2.new(1, -55, 0.5, -10), TitleBar)

    -- Content Area
    ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -30, 1, -70)
    ContentFrame.Position = UDim2.new(0, 15, 0, 60)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainWindow

    -- Navigation Tabs
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 35)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = ContentFrame

    local tabs = {
        {Name = "Player", Icon = "👤"},
        {Name = "Movement", Icon = "⚡"}, 
        {Name = "Visual", Icon = "👁️"},
        {Name = "Teleport", Icon = "📍"},
        {Name = "Performance", Icon = "🚀"}
    }

    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1/#tabs, -8, 1, 0)
        tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        tabButton.BackgroundColor3 = tab.Name == "Player" and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(40, 45, 60)
        tabButton.Text = tab.Name
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 11
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Parent = TabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton

        tabButton.MouseButton1Click:Connect(function()
            SwitchTab(tab.Name)
        end)
    end

    -- Tab Content
    local TabContent = Instance.new("Frame")
    TabContent.Name = "TabContent"
    TabContent.Size = UDim2.new(1, 0, 1, -45)
    TabContent.Position = UDim2.new(0, 0, 0, 45)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = ContentFrame

    CreatePlayerTab(TabContent)
    CreateMovementTab(TabContent)
    CreateVisualTab(TabContent)
    CreateTeleportTab(TabContent)
    CreatePerformanceTab(TabContent)

    -- Hide other tabs initially
    for _, tabName in pairs({"Movement", "Visual", "Teleport", "Performance"}) do
        local tabFrame = TabContent:FindFirstChild(tabName .. "Tab")
        if tabFrame then
            tabFrame.Visible = false
        end
    end

    -- Window Controls
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainWindow.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        _G.XresLoaded = false
    end)

    HideButton.MouseButton1Click:Connect(function()
        IsUIVisible = not IsUIVisible
        if IsUIVisible then
            ContentFrame.Visible = true
            MainWindow.Size = UDim2.new(0, 400, 0, 500)
            HideButton.Text = "−"
            CloseButton.Visible = true
        else
            ContentFrame.Visible = false
            MainWindow.Size = UDim2.new(0, 400, 0, 45)
            HideButton.Text = "+"
            CloseButton.Visible = false
        end
    end)

    return ScreenGui
end

function SwitchTab(tabName)
    CurrentTab = tabName
    
    -- Hide all tabs
    for _, tab in pairs(ContentFrame.TabContent:GetChildren()) do
        if tab:IsA("ScrollingFrame") then
            tab.Visible = false
        end
    end
    
    -- Show selected tab
    local targetTab = ContentFrame.TabContent:FindFirstChild(tabName .. "Tab")
    if targetTab then
        targetTab.Visible = true
    end
    
    -- Update tab buttons colors
    for _, tabButton in pairs(ContentFrame:FindFirstChild("TabContainer"):GetChildren()) do
        if tabButton:IsA("TextButton") then
            tabButton.BackgroundColor3 = tabButton.Text == tabName and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(40, 45, 60)
        end
    end
end

function CreateControlButton(symbol, color, position, parent)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 25, 0, 25)
    button.Position = position
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.BackgroundColor3 = color
    button.Text = symbol
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamBold
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    return button
end

function CreatePlayerTab(parent)
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "PlayerTab"
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
    tab.Parent = parent

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = tab

    -- Speed Control
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, 0, 0, 70)
    speedFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    speedFrame.Parent = tab

    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 10)
    speedCorner.Parent = speedFrame

    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -20, 0, 25)
    speedLabel.Position = UDim2.new(0, 15, 0, 8)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "WALK SPEED"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedFrame

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(1, -30, 0, 32)
    speedBox.Position = UDim2.new(0, 15, 0, 35)
    speedBox.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    speedBox.Text = tostring(Xres.WalkSpeed)
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.PlaceholderText = "16-200"
    speedBox.TextSize = 14
    speedBox.Font = Enum.Font.Gotham
    speedBox.Parent = speedFrame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = speedBox

    speedBox.FocusLost:Connect(function(enterPressed)
        local newSpeed = tonumber(speedBox.Text)
        if newSpeed and newSpeed >= 16 and newSpeed <= 200 then
            Xres.WalkSpeed = newSpeed
            if Humanoid then
                Humanoid.WalkSpeed = newSpeed
            end
        else
            speedBox.Text = tostring(Xres.WalkSpeed)
        end
    end)

    -- Player Features
    CreateFeatureToggle("GOD MODE", "Become invincible", Xres.GodMode, tab, function(state)
        Xres.GodMode = state
        if state then EnableGodMode() end
    end)

    CreateFeatureToggle("ANTI AFK", "Prevent being kicked", Xres.AntiAFK, tab, function(state)
        Xres.AntiAFK = state
        if state then EnableAntiAFK() else DisableAntiAFK() end
    end)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

function CreateMovementTab(parent)
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "MovementTab"
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
    tab.Parent = parent

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = tab

    CreateFeatureToggle("INFINITY JUMP", "Jump infinitely", Xres.InfinityJump, tab, function(state)
        Xres.InfinityJump = state
        if state then EnableInfinityJump() else DisableInfinityJump() end
    end)

    CreateFeatureToggle("NO CLIP", "Walk through walls", Xres.NoClip, tab, function(state)
        Xres.NoClip = state
        if state then EnableNoClip() else DisableNoClip() end
    end)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

function CreateVisualTab(parent)
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "VisualTab"
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
    tab.Parent = parent

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = tab

    -- Character ESP Toggle
    local espToggle = CreateFeatureToggle("PLAYER ESP", "See players through walls", Xres.ESP, tab, function(state)
        Xres.ESP = state
        if Xres.ESP or Xres.NameESP then
            EnableESP()
        else
            DisableESP()
        end
    end)

    -- Name ESP Toggle
    local nameESPToggle = CreateFeatureToggle("NAME ESP", "See player names", Xres.NameESP, tab, function(state)
        Xres.NameESP = state
        if Xres.ESP or Xres.NameESP then
            EnableESP()
        else
            DisableESP()
        end
    end)

    -- ESP Settings
    local espSettingsFrame = Instance.new("Frame")
    espSettingsFrame.Size = UDim2.new(1, 0, 0, 100)
    espSettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    espSettingsFrame.Parent = tab

    local espSettingsCorner = Instance.new("UICorner")
    espSettingsCorner.CornerRadius = UDim.new(0, 10)
    espSettingsCorner.Parent = espSettingsFrame

    local espSettingsLabel = Instance.new("TextLabel")
    espSettingsLabel.Size = UDim2.new(1, -20, 0, 25)
    espSettingsLabel.Position = UDim2.new(0, 15, 0, 8)
    espSettingsLabel.BackgroundTransparency = 1
    espSettingsLabel.Text = "ESP SETTINGS"
    espSettingsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    espSettingsLabel.TextSize = 14
    espSettingsLabel.Font = Enum.Font.GothamBold
    espSettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    espSettingsLabel.Parent = espSettingsFrame

    -- Character ESP Color
    local charColorFrame = Instance.new("Frame")
    charColorFrame.Size = UDim2.new(1, -30, 0, 25)
    charColorFrame.Position = UDim2.new(0, 15, 0, 35)
    charColorFrame.BackgroundTransparency = 1
    charColorFrame.Parent = espSettingsFrame

    local charColorLabel = Instance.new("TextLabel")
    charColorLabel.Size = UDim2.new(0, 120, 1, 0)
    charColorLabel.BackgroundTransparency = 1
    charColorLabel.Text = "Character Color:"
    charColorLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    charColorLabel.TextSize = 12
    charColorLabel.Font = Enum.Font.Gotham
    charColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    charColorLabel.Parent = charColorFrame

    local charColorPicker = CreateColorPicker(Xres.ESPColor, function(newColor)
        Xres.ESPColor = newColor
        -- Update existing ESP highlights
        for player, highlight in pairs(ESPHighlights) do
            if highlight and highlight:IsA("Highlight") then
                highlight.FillColor = newColor
            end
        end
    end, charColorFrame)
    charColorPicker.Position = UDim2.new(1, -30, 0, 0)

    -- Name ESP Color
    local nameColorFrame = Instance.new("Frame")
    nameColorFrame.Size = UDim2.new(1, -30, 0, 25)
    nameColorFrame.Position = UDim2.new(0, 15, 0, 65)
    nameColorFrame.BackgroundTransparency = 1
    nameColorFrame.Parent = espSettingsFrame

    local nameColorLabel = Instance.new("TextLabel")
    nameColorLabel.Size = UDim2.new(0, 120, 1, 0)
    nameColorLabel.BackgroundTransparency = 1
    nameColorLabel.Text = "Name Color:"
    nameColorLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    nameColorLabel.TextSize = 12
    nameColorLabel.Font = Enum.Font.Gotham
    nameColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameColorLabel.Parent = nameColorFrame

    local nameColorPicker = CreateColorPicker(Xres.NameESPColor, function(newColor)
        Xres.NameESPColor = newColor
        -- Update existing name labels
        for player, billboard in pairs(NameLabels) do
            if billboard then
                local textLabel = billboard:FindFirstChildWhichIsA("TextLabel")
                if textLabel then
                    textLabel.TextColor3 = newColor
                end
            end
        end
    end, nameColorFrame)
    nameColorPicker.Position = UDim2.new(1, -30, 0, 0)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

function CreateTeleportTab(parent)
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "TeleportTab"
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
    tab.Parent = parent

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = tab

    -- Player Dropdown
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 120)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    dropdownFrame.Parent = tab

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 10)
    dropdownCorner.Parent = dropdownFrame

    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Size = UDim2.new(1, -20, 0, 25)
    dropdownLabel.Position = UDim2.new(0, 15, 0, 8)
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Text = "SELECT PLAYER"
    dropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
    dropdownLabel.TextSize = 14
    dropdownLabel.Font = Enum.Font.GothamBold
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.Parent = dropdownFrame

    local playerDropdown = Instance.new("TextButton")
    playerDropdown.Size = UDim2.new(1, -30, 0, 35)
    playerDropdown.Position = UDim2.new(0, 15, 0, 35)
    playerDropdown.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
    playerDropdown.Text = "Click to select player"
    playerDropdown.TextColor3 = Color3.fromRGB(180, 180, 200)
    playerDropdown.TextSize = 12
    playerDropdown.Font = Enum.Font.Gotham
    playerDropdown.Parent = dropdownFrame

    local dropdownBtnCorner = Instance.new("UICorner")
    dropdownBtnCorner.CornerRadius = UDim.new(0, 6)
    dropdownBtnCorner.Parent = playerDropdown

    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(1, -30, 0, 35)
    teleportButton.Position = UDim2.new(0, 15, 0, 78)
    teleportButton.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
    teleportButton.Text = "TELEPORT TO PLAYER"
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.TextSize = 14
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.Parent = dropdownFrame

    local teleportCorner = Instance.new("UICorner")
    teleportCorner.CornerRadius = UDim.new(0, 6)
    teleportCorner.Parent = teleportButton

    local selectedPlayer = nil
    
    playerDropdown.MouseButton1Click:Connect(function()
        -- Remove existing menu if any
        local existingMenu = playerDropdown:FindFirstChild("PlayerMenu")
        if existingMenu then
            existingMenu:Destroy()
            return
        end

        local menu = Instance.new("Frame")
        menu.Name = "PlayerMenu"
        menu.Size = UDim2.new(1, 0, 0, 150)
        menu.Position = UDim2.new(0, 0, 1, 5)
        menu.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
        menu.BorderSizePixel = 0
        menu.ZIndex = 5
        menu.Parent = playerDropdown

        local menuCorner = Instance.new("UICorner")
        menuCorner.CornerRadius = UDim.new(0, 6)
        menuCorner.Parent = menu

        local menuScroll = Instance.new("ScrollingFrame")
        menuScroll.Size = UDim2.new(1, -10, 1, -10)
        menuScroll.Position = UDim2.new(0, 5, 0, 5)
        menuScroll.BackgroundTransparency = 1
        menuScroll.ScrollBarThickness = 3
        menuScroll.ZIndex = 5
        menuScroll.Parent = menu

        local menuList = Instance.new("UIListLayout")
        menuList.Parent = menuScroll

        local players = Players:GetPlayers()
        if #players == 1 then -- Only local player
            local noPlayersLabel = Instance.new("TextLabel")
            noPlayersLabel.Size = UDim2.new(1, 0, 0, 30)
            noPlayersLabel.BackgroundTransparency = 1
            noPlayersLabel.Text = "No other players found"
            noPlayersLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
            noPlayersLabel.TextSize = 12
            noPlayersLabel.Font = Enum.Font.Gotham
            noPlayersLabel.Parent = menuScroll
        else
            for _, player in pairs(players) do
                if player ~= LocalPlayer then
                    local playerBtn = Instance.new("TextButton")
                    playerBtn.Size = UDim2.new(1, 0, 0, 28)
                    playerBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 75)
                    playerBtn.Text = player.Name
                    playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    playerBtn.TextSize = 12
                    playerBtn.Font = Enum.Font.Gotham
                    playerBtn.ZIndex = 5
                    playerBtn.Parent = menuScroll

                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 4)
                    btnCorner.Parent = playerBtn

                    playerBtn.MouseButton1Click:Connect(function()
                        selectedPlayer = player
                        playerDropdown.Text = player.Name
                        menu:Destroy()
                    end)
                end
            end
        end

        menuList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            menuScroll.CanvasSize = UDim2.new(0, 0, 0, menuList.AbsoluteContentSize.Y)
        end)
    end)

    teleportButton.MouseButton1Click:Connect(function()
        if selectedPlayer then
            local success = TeleportToPlayer(selectedPlayer)
            if success then
                teleportButton.Text = "TELEPORTED!"
                wait(1)
                teleportButton.Text = "TELEPORT TO PLAYER"
            else
                teleportButton.Text = "FAILED!"
                wait(1)
                teleportButton.Text = "TELEPORT TO PLAYER"
            end
        else
            teleportButton.Text = "SELECT PLAYER FIRST!"
            wait(1)
            teleportButton.Text = "TELEPORT TO PLAYER"
        end
    end)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

function CreatePerformanceTab(parent)
    local tab = Instance.new("ScrollingFrame")
    tab.Name = "PerformanceTab"
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.BackgroundTransparency = 1
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(60, 120, 255)
    tab.Parent = parent

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = tab

    -- FPS Boost
    CreateFeatureToggle("FPS BOOST", "Improve game performance", Xres.FPSBoost, tab, function(state)
        Xres.FPSBoost = state
        if state then 
            EnableFPSBoost()
        else 
            DisableFPSBoost()
        end
    end)

    -- Additional Performance Options
    CreateFeatureToggle("REDUCE PART COUNT", "Remove unnecessary parts", false, tab, function(state)
        if state then
            -- Simple part reduction (can be expanded)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") and obj.Transparency > 0.8 then
                    obj.Transparency = 1
                end
            end
        end
    end)

    -- Performance Info
    local infoFrame = Instance.new("Frame")
    infoFrame.Size = UDim2.new(1, 0, 0, 100)
    infoFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    infoFrame.Parent = tab

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 10)
    infoCorner.Parent = infoFrame

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 1, -20)
    infoLabel.Position = UDim2.new(0, 10, 0, 10)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "FPS Boost Features:\n• Disables shadows\n• Reduces graphics quality\n• Disables visual effects\n• Improves game performance"
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = infoFrame

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

function CreateFeatureToggle(name, description, state, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 25)
    nameLabel.Position = UDim2.new(0, 15, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -80, 0, 18)
    descLabel.Position = UDim2.new(0, 15, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 55, 0, 25)
    button.Position = UDim2.new(1, -65, 0, 15)
    button.BackgroundColor3 = state and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(200, 80, 80)
    button.Text = state and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        local newState = not state
        state = newState
        button.Text = newState and "ON" or "OFF"
        button.BackgroundColor3 = newState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(200, 80, 80)
        callback(newState)
    end)

    return button
end

-- Character Respawn
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

-- Initialize
wait(1)
CreateXresUI()
if Humanoid then
    Humanoid.WalkSpeed = Xres.WalkSpeed
end

print("✅ Xres 1.0.0 Loaded!")
return Xres