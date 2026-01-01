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
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- SHOP LIST (HARUS SESUAI WORKSPACE)
local ShopList = {
    ["Skin Shop"] = "SKIN SHOP",
    ["Bobber Shop"] = "BOBBER SHOP",
    ["Rod Shop"] = "ROD SHOP",
    ["Sell Fish"] = "JUAL IKAN"
}

local SelectedShop = nil

-- TAB
local MainTab = Window:CreateTab("☃️ Main")
local TeleportShopTab = Window:CreateTab("🏝 Teleport Shop")
TeleportShopTab:CreateSection("Teleport Shop")

-- DROPDOWN
TeleportShopTab:CreateDropdown({
    Name = "Select Shop",
    Options = {"Skin Shop", "Bobber Shop", "Rod Shop", "Sell Fish"},
    CurrentOption = nil,
    Callback = function(Value)
        SelectedShop = Value
    end
})

-- BUTTON TELEPORT
TeleportShopTab:CreateButton({
    Name = "Teleport to Shop",
    Callback = function()

        -- CEGAH CALLBACK ERROR
        if not SelectedShop then
            Rayfield:Notify({
                Title = "Error",
                Content = "Pilih shop terlebih dahulu!",
                Duration = 3
            })
            return
        end

        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        local ShopMap = {
            ["Skin Shop"] = "SKIN SHOP",
            ["Bobber Shop"] = "BOBBER SHOP",
            ["Rod Shop"] = "ROD SHOP",
            ["Sell Fish"] = "JUAL IKAN"
        }

        local shop = workspace:FindFirstChild(ShopMap[SelectedShop])

        if not shop then
            Rayfield:Notify({
                Title = "Error",
                Content = "Shop tidak ditemukan!",
                Duration = 3
            })
            return
        end

        hrp.CFrame = shop:GetPivot() + Vector3.new(0,3,0)

        Rayfield:Notify({
            Title = "Success",
            Content = "Teleport ke "..SelectedShop,
            Duration = 3
        })
    end
})

Rayfield:Notify({
    Title = "XresHub",
    Content = "Successfully loaded",
    Duration = 5
})