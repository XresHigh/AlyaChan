local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🐟 Fish It Blatant | v1.0",
    LoadingTitle = "Fish It Blatant",
    LoadingSubtitle = "Loading Auto Farm...",
    ConfigurationSaving = {Enabled = true, FolderName = "FishIt_Blatant", FileName = "Config"},
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

-- Variables
local Connections = {}

-- Auto Farm Variables
local autoFarmEnabled = false
local farmConnection

-- Settings
local FarmSettings = {
    FishingDelay = 3,    -- Delay antara fishing actions
    ReelDelay = 2,       -- Delay setelah dapat fish
    SellDelay = 5,       -- Delay antara sell actions
    MoveToFishingSpot = true,
    MoveToSellSpot = true
}

-- Auto Farm Function
function StartAutoFarm()
    if farmConnection then farmConnection:Disconnect() end
    
    local lastFishingTime = 0
    local lastReelTime = 0
    local lastSellTime = 0
    local isFishing = false
    local hasFish = false
    
    farmConnection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled then return end
        
        local currentTime = tick()
        local character = LocalPlayer.Character
        
        if not character then return end
        
        -- Phase 1: Fishing
        if not hasFish and (currentTime - lastFishingTime) >= FarmSettings.FishingDelay then
            -- Equip fishing rod
            local backpack = LocalPlayer:FindFirstChild("Backpack")
            if backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item.Name:lower():find("rod") or item.Name:lower():find("fishing") then
                        item.Parent = character
                        break
                    end
                end
            end
            
            -- Move to fishing spot
            if FarmSettings.MoveToFishingSpot then
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("Part") and (part.Name:lower():find("water") or part.Name:lower():find("fish") or part.Name:lower():find("pond") or part.Name:lower():find("lake") or part.Name:lower():find("river")) then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            humanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        end
                        break
                    end
                end
            end
            
            -- Start fishing action
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            
            -- Simulate fish catch after delay
            if not isFishing then
                isFishing = true
                spawn(function()
                    wait(FarmSettings.ReelDelay)
                    if autoFarmEnabled then
                        hasFish = true
                        isFishing = false
                        lastReelTime = currentTime
                    end
                end)
            end
            
            lastFishingTime = currentTime
        end
        
        -- Phase 2: Selling (jika sudah dapat fish)
        if hasFish and (currentTime - lastReelTime) >= FarmSettings.SellDelay then
            -- Move to sell spot
            if FarmSettings.MoveToSellSpot then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("sell") or obj.Name:lower():find("shop") or obj.Name:lower():find("merchant") or obj.Name:lower():find("npc") or obj.Name:lower():find("vendor")) then
                        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if humanoidRootPart then
                            humanoidRootPart.CFrame = obj:GetPivot() + Vector3.new(0, 3, 0)
                        end
                        break
                    end
                end
            end
            
            -- Sell action
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            
            -- Reset untuk fishing lagi
            hasFish = false
            lastSellTime = currentTime
        end
    end)
end

function StopAutoFarm()
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
end

-- UI Setup
local BlatantTab = Window:CreateTab("Blatant")

-- Auto Farm Section
BlatantTab:CreateSection("Auto Farm Settings")

BlatantTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        autoFarmEnabled = Value
        if Value then
            StartAutoFarm()
            Rayfield:Notify({
                Title = "Auto Farm",
                Content = "Auto Farming activated!",
                Duration = 3
            })
        else
            StopAutoFarm()
            Rayfield:Notify({
                Title = "Auto Farm",
                Content = "Auto Farming deactivated!",
                Duration = 3
            })
        end
    end,
})

BlatantTab:CreateSlider({
    Name = "Fishing Delay",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "seconds",
    CurrentValue = 3,
    Flag = "FishingDelay",
    Callback = function(Value)
        FarmSettings.FishingDelay = Value
    end,
})

BlatantTab:CreateSlider({
    Name = "Reel Delay",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "seconds",
    CurrentValue = 2,
    Flag = "ReelDelay",
    Callback = function(Value)
        FarmSettings.ReelDelay = Value
    end,
})

BlatantTab:CreateSlider({
    Name = "Sell Delay",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "seconds",
    CurrentValue = 5,
    Flag = "SellDelay",
    Callback = function(Value)
        FarmSettings.SellDelay = Value
    end,
})

BlatantTab:CreateToggle({
    Name = "Move to Fishing Spot",
    CurrentValue = true,
    Flag = "MoveToFishing",
    Callback = function(Value)
        FarmSettings.MoveToFishingSpot = Value
    end,
})

BlatantTab:CreateToggle({
    Name = "Move to Sell Spot",
    CurrentValue = true,
    Flag = "MoveToSell",
    Callback = function(Value)
        FarmSettings.MoveToSellSpot = Value
    end,
})

-- Status Display
BlatantTab:CreateSection("Farm Status")

local statusLabel = BlatantTab:CreateLabel("Status: Ready")

-- Update status
spawn(function()
    while true do
        wait(1)
        if autoFarmEnabled then
            statusLabel:Set("Status: Auto Farming...")
        else
            statusLabel:Set("Status: Ready")
        end
    end
end)

-- Info Section
BlatantTab:CreateSection("Information")

BlatantTab:CreateLabel("Auto Farm akan:")
BlatantTab:CreateLabel("1. Equip fishing rod")
BlatantTab:CreateLabel("2. Pindah ke fishing spot")
BlatantTab:CreateLabel("3. Fishing dengan delay")
BlatantTab:CreateLabel("4. Reel fish setelah delay")
BlatantTab:CreateLabel("5. Pindah ke sell spot")
BlatantTab:CreateLabel("6. Sell fish")
BlatantTab:CreateLabel("7. Ulangi dari awal")

-- Notify ketika load
Rayfield:Notify({
    Title = "Fish It Blatant",
    Content = "Auto Farm loaded! Configure delays in settings.",
    Duration = 5
})
