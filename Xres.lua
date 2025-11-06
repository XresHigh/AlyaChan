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

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Config
local Xres = {
    WalkSpeed = 16,
    ESP = false,
    NoClip = false,
    GodMode = false,
    InfinityJump = false,
    AntiAFK = false
}

-- Variables
local Connections = {}
local ESPHighlights = {}

-- Functions
function EnableESP()
    Connections.ESP = RunService.Heartbeat:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if not ESPHighlights[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                    ESPHighlights[player] = highlight
                end
            end
        end
    end)
end

function DisableESP()
    if Connections.ESP then Connections.ESP:Disconnect() end
    for _, highlight in pairs(ESPHighlights) do
        highlight:Destroy()
    end
    ESPHighlights = {}
end

function EnableNoClip()
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
    if Connections.NoClip then Connections.NoClip:Disconnect() end
end

function EnableInfinityJump()
    Connections.InfinityJump = UserInputService.JumpRequest:Connect(function()
        if Xres.InfinityJump and Character and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function DisableInfinityJump()
    if Connections.InfinityJump then Connections.InfinityJump:Disconnect() end
end

function EnableAntiAFK()
    Connections.AntiAFK = Players.LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

function DisableAntiAFK()
    if Connections.AntiAFK then Connections.AntiAFK:Disconnect() end
end

function EnableGodMode()
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj.Name == "VitalityBridge" then
            obj:Destroy()
        end
    end
end

function TeleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        RootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
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

    -- Main Window
    MainWindow = Instance.new("Frame")
    MainWindow.Size = UDim2.new(0, 360, 0, 450)
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
        {Name = "Teleport", Icon = "📍"}
    }

    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1/#tabs, -8, 1, 0)
        tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        tabButton.BackgroundColor3 = tab.Name == "Player" and Color3.fromRGB(60, 120, 255) or Color3.fromRGB(40, 45, 60)
        tabButton.Text = tab.Name
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 12
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

    -- Hide other tabs initially
    for _, tabName in pairs({"Movement", "Visual", "Teleport"}) do
        TabContent:FindFirstChild(tabName .. "Tab").Visible = false
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
            MainWindow.Size = UDim2.new(0, 360, 0, 450)
            HideButton.Text = "−"
            CloseButton.Visible = true
        else
            ContentFrame.Visible = false
            MainWindow.Size = UDim2.new(0, 360, 0, 45)
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

    speedBox.FocusLost:Connect(function()
        local newSpeed = tonumber(speedBox.Text)
        if newSpeed and newSpeed >= 16 and newSpeed <= 200 then
            Xres.WalkSpeed = newSpeed
            Humanoid.WalkSpeed = newSpeed
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

    CreateFeatureToggle("PLAYER ESP", "See players through walls", Xres.ESP, tab, function(state)
        Xres.ESP = state
        if state then EnableESP() else DisableESP() end
    end)

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
        local menu = Instance.new("Frame")
        menu.Size = UDim2.new(1, 0, 0, 120)
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

        for _, player in pairs(Players:GetPlayers()) do
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
    Humanoid.WalkSpeed = Xres.WalkSpeed
    if Xres.ESP then EnableESP() end
    if Xres.NoClip then EnableNoClip() end
    if Xres.InfinityJump then EnableInfinityJump() end
    if Xres.AntiAFK then EnableAntiAFK() end
    if Xres.GodMode then EnableGodMode() end
end

-- Auto God Mode
game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(obj)
    if Xres.GodMode and obj.Name == "VitalityBridge" then
        obj:Destroy()
    end
end

-- Initialize
wait(1)
CreateXresUI()
Humanoid.WalkSpeed = Xres.WalkSpeed

print("✅ Xres 1.0.0 Loaded!")
return Xres
