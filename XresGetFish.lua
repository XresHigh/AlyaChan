local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

if game.PlaceId ~= 78632820802305 then
    return
end

-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "XpoGetFish | Version 1.0.0",
    LoadingTitle = "XpoHub",
    LoadingSubtitle = "1.0.0",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "XpoGetFish",
        FileName = "Xpo"
    },
    KeySystem = false
})

-- SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- TAB
local MainTab = Window:CreateTab("☃️ Main")
local TeleportShopTab = Window:CreateTab("🏝 Teleport Shop")

-- SECTION
TeleportShopTab:CreateSection("🛒 Teleport Shop")
MainTab:CreateSection("🚀 Movement Features")
MainTab:CreateSection("⚡ Speed")

-- BUTTON
local infinityToggle = MainTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Flag = "InfinityJumpToggle",
    Callback = function(value)
        infinityJumpEnabled = value
        
        if value then
            -- Aktifkan infinity jump
            Rayfield:Notify({
                Title = "Infinity Jump",
                Content = "Enabled! Press Space to jump infinitely",
                Duration = 3
            })
            print("Infinity Jump enabled")
            
            -- Connect jump listener
            local jumpConnection
            jumpConnection = UserInputService.JumpRequest:Connect(function()
                if infinityJumpEnabled and player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid:ChangeState("Jumping")
                    end
                end
            end)
            
            -- Simpan connection untuk di-disconnect nanti
            getgenv().infinityJumpConnection = jumpConnection
            
        else
            -- Nonaktifkan infinity jump
            Rayfield:Notify({
                Title = "Infinity Jump",
                Content = "Disabled",
                Duration = 2
            })
            print("Infinity Jump disabled")
            
            -- Disconnect listener
            if getgenv().infinityJumpConnection then
                getgenv().infinityJumpConnection:Disconnect()
                getgenv().infinityJumpConnection = nil
            end
        end
    end
})

local noClipToggle = MainTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(value)
        noClipEnabled = value
        
        if value then
            -- Aktifkan No Clip
            Rayfield:Notify({
                Title = "No Clip",
                Content = "Enabled! You can walk through walls",
                Duration = 3
            })
            print("No Clip enabled")
            
            -- Start noclip loop
            if noclipConnection then
                noclipConnection:Disconnect()
            end
            
            noclipConnection = RunService.Stepped:Connect(function()
                if noClipEnabled and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            
        else
            -- Nonaktifkan No Clip
            Rayfield:Notify({
                Title = "No Clip",
                Content = "Disabled",
                Duration = 2
            })
            print("No Clip disabled")
            
            -- Disconnect noclip loop
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            -- Restore collision
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})



local speedMultiplier = 1
local speedSlider = MainTab:CreateSlider({
    Name = "Walk Speed Multiplier",
    Range = {1, 10},
    Increment = 0.5,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "SpeedSlider",
    Callback = function(value)
        speedMultiplier = value
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * value
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Set Default Speed",
    Callback = function()
        speedSlider:Set(1)
        if player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end
})

-- List shop dan nama displaynya
local QuickShops = {
    {"🎣 Skin Shop", "SKIN SHOP"},
    {"🪱 Bobber Shop", "BOBBER SHOP"},
    {"🎣 Rod Shop", "ROD SHOP"},
    {"💰 Sell Fish", "JUAL IKAN"}
}

for _, shopData in ipairs(QuickShops) do
    local displayName = shopData[1]
    local shopName = shopData[2]
    
    TeleportShopTab:CreateButton({
        Name = displayName,
        Callback = function()
            -- Update dropdown selection
            SelectedTeleport = shopName
            LocationDropdown:Set(shopName)
            
            -- Teleport langsung
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            local targetShop = Workspace:FindFirstChild(shopName)
            
            if targetShop then
                if targetShop:IsA("Model") and targetShop.PrimaryPart then
                    humanoidRootPart.CFrame = targetShop.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                else
                    humanoidRootPart.CFrame = targetShop:GetPivot() + Vector3.new(0, 3, 0)
                end
                
                Rayfield:Notify({
                    Title = "✅ Berhasil",
                    Content = "Telah teleport ke " .. displayName,
                    Duration = 3
                })
            end
        end
    })
end

Rayfield:Notify({
    Title = "XresHub",
    Content = "Successfully loaded",
    Duration = 5
})