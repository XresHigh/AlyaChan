local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Xres | Version 1.0.0",
    LoadingTitle = "XresHub",
    LoadingSubtitle = "1.0.0",
    ConfigurationSaving = {Enabled = true, FolderName = "Xres_Suite", FileName = "Xres_config_v3"},
    KeySystem = false
})

-- Tab utama
local MainTab = Window:CreateTab("ESP")

-- Toggle ESP Player
local ESPEnabled = false
local ESPToggle = MainTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            createESP()
        else
            removeESP()
        end
    end,
})

-- Toggle untuk Name Tags
local ShowNames = true
local NameToggle = MainTab:CreateToggle({
    Name = "NameTags",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(Value)
        ShowNames = Value
        updateNameTags()
    end,
})

-- Color Picker untuk ESP
local ESPColor = Color3.fromRGB(255, 0, 0)
local ColorPicker = MainTab:CreateColorPicker({
    Name = "PlayerEsp",
    Color = ESPColor,
    Flag = "ESPColor",
    Callback = function(Value)
        ESPColor = Value
        updateESPColor()
    end
})

-- Variabel untuk menyimpan ESP objects
local ESPObjects = {}
local Connections = {}

-- Fungsi untuk membuat ESP
function createESP()
    removeESP() -- Hapus ESP lama terlebih dahulu
    
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    local runService = game:GetService("RunService")
    
    -- Function untuk membuat ESP untuk satu player
    local function createPlayerESP(player)
        if player == localPlayer then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid then return end
        
        -- Create Highlight untuk player ESP
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.Adornee = character
        highlight.FillColor = ESPColor
        highlight.OutlineColor = ESPColor
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        
        -- Create BillboardGui untuk name tag
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Adornee = humanoidRootPart
        billboard.Size = UDim2.new(0, 200, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = ShowNames
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "ESP_Name"
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = ESPColor
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = billboard
        
        billboard.Parent = humanoidRootPart
        
        -- Simpan ESP objects
        ESPObjects[player] = {
            Highlight = highlight,
            Billboard = billboard,
            Character = character
        }
        
        -- Update loop untuk name tag visibility
        local connection
        connection = runService.Heartbeat:Connect(function()
            if not ESPEnabled or not character or not humanoidRootPart or not humanoid then
                if connection then
                    connection:Disconnect()
                end
                return
            end
            
            -- Update name tag visibility
            if billboard then
                billboard.Enabled = ShowNames
            end
        end)
        
        table.insert(Connections, connection)
    end
    
    -- Buat ESP untuk semua player yang sudah ada
    for _, player in pairs(players:GetPlayers()) do
        createPlayerESP(player)
    end
    
    -- Connect untuk player baru
    local playerAddedConnection = players.PlayerAdded:Connect(function(player)
        if ESPEnabled then
            createPlayerESP(player)
        end
    end)
    
    table.insert(Connections, playerAddedConnection)
    
    -- Connect untuk character added
    local characterAddedConnection = players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            if ESPEnabled then
                wait(1) -- Tunggu character fully loaded
                createPlayerESP(player)
            end
        end)
    end)
    
    table.insert(Connections, characterAddedConnection)
end

-- Fungsi untuk menghapus ESP
function removeESP()
    -- Hapus semua connections
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    Connections = {}
    
    -- Hapus semua ESP objects
    for player, espData in pairs(ESPObjects) do
        if espData.Highlight then
            espData.Highlight:Destroy()
        end
        if espData.Billboard then
            espData.Billboard:Destroy()
        end
    end
    ESPObjects = {}
end

-- Fungsi untuk update name tags
function updateNameTags()
    for player, espData in pairs(ESPObjects) do
        if espData.Billboard then
            espData.Billboard.Enabled = ShowNames
        end
    end
end

-- Fungsi untuk update warna ESP
function updateESPColor()
    for player, espData in pairs(ESPObjects) do
        if espData.Highlight then
            espData.Highlight.FillColor = ESPColor
            espData.Highlight.OutlineColor = ESPColor
        end
        if espData.Billboard then
            local nameLabel = espData.Billboard:FindFirstChild("ESP_Name")
            if nameLabel then
                nameLabel.TextColor3 = ESPColor
            end
        end
    end
end

-- Notifikasi ketika load
Rayfield:Notify({
    Title = "XresHub",
    Content = "ESP System Loaded",
    Duration = 3
})