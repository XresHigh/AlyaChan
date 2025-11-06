-- Xres 1.0.0 - Clean Version
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
    Settings = {
        WalkSpeed = 16,
        ESP = false,
        NoClip = false,
        GodMode = false,
        InfinityJump = false,
        AntiAFK = false
    }
}

-- Variables
local Connections = {}
local ESPHighlights = {}

-- 📍 Teleport to Player
function TeleportToPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        RootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        return true
    end
    return false
end

-- ∞ Infinity Jump
function EnableInfinityJump()
    Connections.InfinityJump = UserInputService.JumpRequest:Connect(function()
        if Xres.Settings.InfinityJump and Character and Humanoid then
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

-- ⏰ Anti AFK
function EnableAntiAFK()
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

-- 👁️ ESP
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
    if Connections.ESP then
        Connections.ESP:Disconnect()
        Connections.ESP = nil
    end
    for _, highlight in pairs(ESPHighlights) do
        highlight:Destroy()
    end
    ESPHighlights = {}
end

-- 🚷 No Clip
function EnableNoClip()
    Connections.NoClip = RunService.Stepped:Connect(function()
        if Xres.Settings.NoClip and Character then
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

-- 🛡️ God Mode
function EnableGodMode()
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj.Name == "VitalityBridge" then
            obj:Destroy()
        end
    end
end

-- 🎨 CLEAN TABBED UI
local MainWindow, TitleBar, ContentFrame, TabButtons = {}
local IsUIVisible = true
local CurrentTab = "Player"

function CreateCleanUI()
    -- Cleanup existing UI
    if CoreGui:FindFirstChild("XresCleanUI") then
        CoreGui:FindFirstChild("XresCleanUI"):Destroy()
    end

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XresCleanUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Window Container
    MainWindow = Instance.new("Frame")
    MainWindow.Size = UDim2.new(0, 380, 0, 420)
    MainWindow.Position = UDim2.new(0, 20, 0, 20)
    MainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainWindow.BorderSizePixel = 0
    MainWindow.ClipsDescendants = true
    MainWindow.Parent = ScreenGui

    -- Modern Corner Radius
    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 12)
    WindowCorner.Parent = MainWindow

    -- Premium Stroke
    local WindowStroke = Instance.new("UIStroke")
    WindowStroke.Color = Color3.fromRGB(100, 70, 200)
    WindowStroke.Thickness = 2
    WindowStroke.Parent = MainWindow

    -- Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 35))
    })
    Gradient.Rotation = 45
    Gradient.Parent = MainWindow

    -- Title Bar with Controls
    TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainWindow

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 12)
    TitleBarCorner.Parent = TitleBar

    -- Title with Icon
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 180, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ XRES 1.0.0"
    Title.TextColor3 = Color3.fromRGB(170, 120, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBlack
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    -- Window Control Buttons
    local ShowHideButton = CreateControlButton("−", Color3.fromRGB(255, 180, 60), UDim2.new(1, -15, 0.5, -10), TitleBar)
    local CloseButton = CreateControlButton("×", Color3.fromRGB(255, 80, 80), UDim2.new(1, -45, 0.5, -10), TitleBar)

    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -20, 0, 35)
    TabContainer.Position = UDim2.new(0, 10, 0, 45)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainWindow

    -- Create Tabs
    local tabs = {
        {Name = "Player", Icon = "👤"},
        {Name = "Movement", Icon = "🚀"}, 
        {Name = "Visual", Icon = "👁️"},
        {Name = "Teleport", Icon = "📍"}
    }

    for i, tab in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1/#tabs, -5, 1, 0)
        tabButton.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        tabButton.BackgroundColor3 = tab.Name == "Player" and Color3.fromRGB(80, 60, 160) or Color3.fromRGB(50, 50, 80)
        tabButton.Text = tab.Icon .. " " .. tab.Name
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 11
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Parent = TabContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton

        TabButtons[tab.Name] = tabButton

        tabButton.MouseButton1Click:Connect(function()
            SwitchTab(tab.Name)
        end)
    end

    -- Content Area
    ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -20, 1, -90)
    ContentFrame.Position = UDim2.new(0, 10, 0, 85)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainWindow

    -- Create Tab Contents
    CreatePlayerTab()
    CreateMovementTab()
    CreateVisualTab()
    CreateTeleportTab()

    -- Hide other tabs initially
    for _, tabName in pairs({"Movement", "Visual", "Teleport"}) do
        ContentFrame:FindFirstChild(tabName .. "Content").Visible = false
    end

    -- 🎯 WINDOW CONTROLS

    -- Dragging System
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
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

    -- Close Button
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        _G.XresLoaded = false
    end)

    -- Show/Hide Button
    ShowHideButton.MouseButton1Click:Connect(function()
        IsUIVisible = not IsUIVisible
        
        if IsUIVisible then
            -- Show UI
            ContentFrame.Visible = true
            TabContainer.Visible = true
            MainWindow.Size = UDim2.new(0, 380, 0, 420)
            ShowHideButton.Text = "−"
            CloseButton.Visible = true
        else
            -- Hide UI (hanya title bar)
            ContentFrame.Visible = false
            TabContainer.Visible = false
            MainWindow.Size = UDim2.new(0, 380, 0, 40)
            ShowHideButton.Text = "+"
            CloseButton.Visible = false
        end
    end)

    return ScreenGui
end

-- Tab Switching Function
function SwitchTab(tabName)
    CurrentTab = tabName
    
    -- Hide all content
    for _, content in pairs(ContentFrame:GetChildren()) do
        if content:IsA("Frame") then
            content.Visible = false
        end
    end
    
    -- Show selected content
    local targetContent = ContentFrame:FindFirstChild(tabName .. "Content")
    if targetContent then
        targetContent.Visible = true
    end
    
    -- Update tab buttons colors
    for name, button in pairs(TabButtons) do
        button.BackgroundColor3 = name == tabName and Color3.fromRGB(80, 60, 160) or Color3.fromRGB(50, 50, 80)
    end
end

-- 👤 PLAYER TAB
function CreatePlayerTab()
    local content = Instance.new("ScrollingFrame")
    content.Name = "PlayerContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 200)
    content.Parent = ContentFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 12)
    list.Parent = content

    -- God Mode
    CreateFeatureToggle("🛡️ GOD MODE", "Become invincible", Xres.Settings.GodMode, content, function(state)
        Xres.Settings.GodMode = state
        if state then EnableGodMode() end
    end)

    -- Anti AFK
    CreateFeatureToggle("⏰ ANTI AFK", "Prevent being kicked", Xres.Settings.AntiAFK, content, function(state)
        Xres.Settings.AntiAFK = state
        if state then EnableAntiAFK() else DisableAntiAFK() end
    end)

    -- Speed Control
    CreateSpeedControl(content)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

-- 🚀 MOVEMENT TAB
function CreateMovementTab()
    local content = Instance.new("ScrollingFrame")
    content.Name = "MovementContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 200)
    content.Parent = ContentFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 12)
    list.Parent = content

    -- Movement Features
    CreateFeatureToggle("∞ INFINITY JUMP", "Jump infinitely in air", Xres.Settings.InfinityJump, content, function(state)
        Xres.Settings.InfinityJump = state
        if state then EnableInfinityJump() else DisableInfinityJump() end
    end)

    CreateFeatureToggle("🚷 NO CLIP", "Walk through walls", Xres.Settings.NoClip, content, function(state)
        Xres.Settings.NoClip = state
        if state then EnableNoClip() else DisableNoClip() end
    end)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

-- 👁️ VISUAL TAB
function CreateVisualTab()
    local content = Instance.new("ScrollingFrame")
    content.Name = "VisualContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 200)
    content.Parent = ContentFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 12)
    list.Parent = content

    -- Visual Features
    CreateFeatureToggle("👁️ PLAYER ESP", "See players through walls", Xres.Settings.ESP, content, function(state)
        Xres.Settings.ESP = state
        if state then EnableESP() else DisableESP() end
    end)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

-- 📍 TELEPORT TAB
function CreateTeleportTab()
    local content = Instance.new("ScrollingFrame")
    content.Name = "TeleportContent"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 200)
    content.Parent = ContentFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 12)
    list.Parent = content

    -- Player Dropdown
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 120)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    DropdownFrame.Parent = content

    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame

    local DropdownStroke = Instance.new("UIStroke")
    DropdownStroke.Color = Color3.fromRGB(70, 50, 150)
    DropdownStroke.Thickness = 1
    DropdownStroke.Parent = DropdownFrame

    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(1, -20, 0, 25)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 5)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = "SELECT PLAYER:"
    DropdownLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    DropdownLabel.TextSize = 14
    DropdownLabel.Font = Enum.Font.GothamBold
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame

    -- Player Dropdown
    local PlayerDropdown = Instance.new("TextButton")
    PlayerDropdown.Size = UDim2.new(1, -20, 0, 35)
    PlayerDropdown.Position = UDim2.new(0, 10, 0, 30)
    PlayerDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    PlayerDropdown.Text = "👥 Click to select player"
    PlayerDropdown.TextColor3 = Color3.fromRGB(200, 200, 200)
    PlayerDropdown.TextSize = 12
    PlayerDropdown.Font = Enum.Font.Gotham
    PlayerDropdown.Parent = DropdownFrame

    local DropdownCorner2 = Instance.new("UICorner")
    DropdownCorner2.CornerRadius = UDim.new(0, 6)
    DropdownCorner2.Parent = PlayerDropdown

    -- Teleport Button
    local TeleportButton = Instance.new("TextButton")
    TeleportButton.Size = UDim2.new(1, -20, 0, 35)
    TeleportButton.Position = UDim2.new(0, 10, 0, 75)
    TeleportButton.BackgroundColor3 = Color3.fromRGB(80, 60, 160)
    TeleportButton.Text = "🚀 TELEPORT TO PLAYER"
    TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportButton.TextSize = 14
    TeleportButton.Font = Enum.Font.GothamBold
    TeleportButton.Parent = DropdownFrame

    local TeleportCorner = Instance.new("UICorner")
    TeleportCorner.CornerRadius = UDim.new(0, 6)
    TeleportCorner.Parent = TeleportButton

    -- Dropdown functionality
    local SelectedPlayer = nil
    PlayerDropdown.MouseButton1Click:Connect(function()
        local DropdownMenu = Instance.new("Frame")
        DropdownMenu.Size = UDim2.new(1, 0, 0, 150)
        DropdownMenu.Position = UDim2.new(0, 0, 1, 5)
        DropdownMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        DropdownMenu.BorderSizePixel = 0
        DropdownMenu.ZIndex = 5
        DropdownMenu.Parent = PlayerDropdown

        local MenuCorner = Instance.new("UICorner")
        MenuCorner.CornerRadius = UDim.new(0, 6)
        MenuCorner.Parent = DropdownMenu

        local MenuScroll = Instance.new("ScrollingFrame")
        MenuScroll.Size = UDim2.new(1, -10, 1, -10)
        MenuScroll.Position = UDim2.new(0, 5, 0, 5)
        MenuScroll.BackgroundTransparency = 1
        MenuScroll.ScrollBarThickness = 4
        MenuScroll.ZIndex = 5
        MenuScroll.Parent = DropdownMenu

        local MenuList = Instance.new("UIListLayout")
        MenuList.Parent = MenuScroll

        -- Add players to dropdown
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local PlayerButton = Instance.new("TextButton")
                PlayerButton.Size = UDim2.new(1, 0, 0, 30)
                PlayerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                PlayerButton.Text = "👤 " .. player.Name
                PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                PlayerButton.TextSize = 12
                PlayerButton.Font = Enum.Font.Gotham
                PlayerButton.ZIndex = 5
                PlayerButton.Parent = MenuScroll

                local PlayerCorner = Instance.new("UICorner")
                PlayerCorner.CornerRadius = UDim.new(0, 4)
                PlayerCorner.Parent = PlayerButton

                PlayerButton.MouseButton1Click:Connect(function()
                    SelectedPlayer = player
                    PlayerDropdown.Text = "👤 " .. player.Name
                    DropdownMenu:Destroy()
                end)
            end
        end

        MenuList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            MenuScroll.CanvasSize = UDim2.new(0, 0, 0, MenuList.AbsoluteContentSize.Y)
        end)
    end)

    TeleportButton.MouseButton1Click:Connect(function()
        if SelectedPlayer then
            TeleportToPlayer(SelectedPlayer)
        else
            print("❌ Please select a player first!")
        end
    end)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
    end)
end

-- UI Helper Functions
function CreateControlButton(symbol, color, position, parent)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 25, 0, 25)
    button.Position = position
    button.AnchorPoint = Vector2.new(1, 0.5)
    button.BackgroundColor3 = color
    button.Text = symbol
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    return button
end

function CreateSpeedControl(parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 80)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 50, 150)
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = "🏃 WALK SPEED"
    label.TextColor3 = Color3.fromRGB(220, 220, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 25)
    valueLabel.Position = UDim2.new(1, -70, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = Xres.Settings.WalkSpeed
    valueLabel.TextColor3 = Color3.fromRGB(170, 120, 255)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0, 30)
    textBox.Position = UDim2.new(0, 10, 0, 35)
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    textBox.Text = tostring(Xres.Settings.WalkSpeed)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderText = "Enter speed (16-200)"
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Gotham
    textBox.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = textBox

    textBox.FocusLost:Connect(function()
        local newSpeed = tonumber(textBox.Text)
        if newSpeed and newSpeed >= 16 and newSpeed <= 200 then
            Xres.Settings.WalkSpeed = newSpeed
            Humanoid.WalkSpeed = newSpeed
            valueLabel.Text = newSpeed
            textBox.Text = tostring(newSpeed)
        else
            textBox.Text = tostring(Xres.Settings.WalkSpeed)
        end
    end)
end

function CreateFeatureToggle(name, description, state, parent, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 50, 150)
    stroke.Thickness = 1
    stroke.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -80, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 25)
    button.Position = UDim2.new(1, -70, 0, 17)
    button.BackgroundColor3 = state and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(255, 60, 80)
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
        button.BackgroundColor3 = newState and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(255, 60, 80)
        callback(newState)
    end)

    return button
end

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    
    wait(1)
    Humanoid.WalkSpeed = Xres.Settings.WalkSpeed
    
    -- Re-apply settings
    if Xres.Settings.ESP then EnableESP() end
    if Xres.Settings.NoClip then EnableNoClip() end
    if Xres.Settings.InfinityJump then EnableInfinityJump() end
    if Xres.Settings.AntiAFK then EnableAntiAFK() end
    if Xres.Settings.GodMode then EnableGodMode() end
end

-- Auto God Mode
game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(obj)
    if Xres.Settings.GodMode and obj.Name == "VitalityBridge" then
        obj:Destroy()
    end
end

-- Initialize
wait(1)
CreateCleanUI()
Humanoid.WalkSpeed = Xres.Settings.WalkSpeed

print("✅ Xres 1.0.0 Clean Version Loaded!")
print("🎮 Tabs: Player, Movement, Visual, Teleport")

return Xres
