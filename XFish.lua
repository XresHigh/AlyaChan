-- WindUI Enhanced Roblox Executor
-- CrayxGremory Shadow Mode v99

-- Load WindUI
local success, errorMsg = pcall(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/main_example.lua'))()
end)

if not success then
    warn("Failed to load WindUI: " .. errorMsg)
    return
end

-- Wait for WindUI to load
repeat task.wait() until _G.WindUI

-- Initialize WindUI
local Library = _G.WindUI
local Window = Library:Window({
    Text = "CrayxExecuted v6.6.6 | WindUI",
    Position = UDim2.new(0.5, -200, 0.5, -200)
})

-- Main Tabs
local MainTab = Window:Tab("Main")
local PlayerTab = Window:Tab("Player")
local CombatTab = Window:Tab("Combat")
local TeleportTab = Window:Tab("Teleport")
local MiscTab = Window:Tab("Misc")
local SettingsTab = Window:Tab("Settings")

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Global Variables
local Connections = {}
local ESPObjects = {}
local NoClipConnection = nil
local SpeedValue = 16
local JumpPowerValue = 50
local GravityValue = 196.2
local FlyEnabled = false
local FlySpeed = 50
local NoclipEnabled = false
local InfiniteJumpEnabled = false
local AntiAFKEnabled = true
local ESPEnabled = false

-- ================== MAIN TAB ==================
local MainSection = MainTab:Section({
    Text = "Executor"
})

local scriptBox = MainSection:Textbox({
    Text = "Script Input",
    Placeholder = "Paste script here...",
    Default = "",
    ClearTextOnFocus = true
})

MainSection:Button({
    Text = "Execute Script",
    Callback = function()
        local scriptText = scriptBox:Get()
        if scriptText and scriptText ~= "" then
            local success, err = pcall(function()
                loadstring(scriptText)()
            end)
            if not success then
                warn("Execution Error: " .. err)
            end
        end
    end
})

MainSection:Button({
    Text = "Clear Output",
    Callback = function()
        scriptBox:Set("")
    end
})

local ScriptsDropdown = MainSection:Dropdown({
    Text = "Quick Scripts",
    Options = {
        "Infinite Yield",
        "Dark Dex",
        "Remote Spy",
        "Simple ESP",
        "Chat Logger",
        "Anti Lag",
        "FPS Boost",
        "Reach Modifier"
    },
    Default = "Select Script"
})

MainSection:Button({
    Text = "Load Selected",
    Callback = function()
        local selected = ScriptsDropdown:Get()
        
        local scripts = {
            ["Infinite Yield"] = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            end,
            ["Dark Dex"] = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua'))()
            end,
            ["Remote Spy"] = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua'))()
            end,
            ["Simple ESP"] = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/zntly/highlight-esp/main/esp.lua'))()
            end,
            ["Chat Logger"] = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/FilteringEnabled/Stringless/main/ChatLogger.lua'))()
            end,
            ["Anti Lag"] = function()
                for _, v in pairs(game:GetDescendants()) do
                    if v:IsA("BasePart") and not v.Anchored then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                    elseif v:IsA("Decal") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Enabled = false
                    end
                end
            end,
            ["FPS Boost"] = function()
                local Settings = UserSettings()
                local GameSettings = Settings.GameSettings
                
                GameSettings.RenderDistance = 100
                GameSettings.ShadowQuality = 0
                GameSettings.MasterVolume = 0
                
                settings().Rendering.QualityLevel = 1
                settings().Rendering.MeshCacheSize = 0
                
                for _, light in pairs(Workspace:GetDescendants()) do
                    if light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight") then
                        light.Enabled = false
                    end
                end
            end,
            ["Reach Modifier"] = function()
                local mt = getrawmetatable(game)
                local oldNamecall = mt.__namecall
                
                setreadonly(mt, false)
                
                mt.__namecall = newcclosure(function(self, ...)
                    local args = {...}
                    local method = getnamecallmethod()
                    
                    if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                        if tostring(self) == "Workspace" then
                            local ray = args[1]
                            if ray then
                                local newRay = Ray.new(ray.Origin, ray.Direction * 50)
                                args[1] = newRay
                            end
                        end
                    end
                    
                    return oldNamecall(self, unpack(args))
                end)
                
                setreadonly(mt, true)
            end
        }
        
        if scripts[selected] then
            scripts[selected]()
        end
    end
})

-- ================== PLAYER TAB ==================
local MovementSection = PlayerTab:Section({
    Text = "Movement"
})

local SpeedToggle = MovementSection:Toggle({
    Text = "Speed Hack",
    Default = false,
    Callback = function(state)
        if state then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = SpeedValue
            end
            table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(1)
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.WalkSpeed = SpeedValue
                end
            end))
        else
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end
})

local SpeedSlider = MovementSection:Slider({
    Text = "Speed Value",
    Default = 16,
    Minimum = 16,
    Maximum = 500,
    Callback = function(value)
        SpeedValue = value
        if SpeedToggle:Get() then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end
})

local JumpToggle = MovementSection:Toggle({
    Text = "Jump Power",
    Default = false,
    Callback = function(state)
        if state then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = JumpPowerValue
            end
            table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(1)
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum.JumpPower = JumpPowerValue
                end
            end))
        else
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50
            end
        end
    end
})

local JumpSlider = MovementSection:Slider({
    Text = "Jump Power Value",
    Default = 50,
    Minimum = 50,
    Maximum = 500,
    Callback = function(value)
        JumpPowerValue = value
        if JumpToggle:Get() then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = value
            end
        end
    end
})

local GravityToggle = MovementSection:Toggle({
    Text = "Gravity Hack",
    Default = false,
    Callback = function(state)
        if state then
            Workspace.Gravity = GravityValue
        else
            Workspace.Gravity = 196.2
        end
    end
})

local GravitySlider = MovementSection:Slider({
    Text = "Gravity Value",
    Default = 196.2,
    Minimum = 0,
    Maximum = 500,
    Callback = function(value)
        GravityValue = value
        if GravityToggle:Get() then
            Workspace.Gravity = value
        end
    end
})

local FlyToggle = MovementSection:Toggle({
    Text = "Fly",
    Default = false,
    Callback = function(state)
        FlyEnabled = state
        
        if FlyEnabled then
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Name = "CrayxFly"
            BodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    BodyVelocity.Parent = root
                    
                    table.insert(Connections, RunService.Heartbeat:Connect(function()
                        if FlyEnabled and char and root then
                            local cam = Workspace.CurrentCamera
                            local moveDirection = Vector3.new(0, 0, 0)
                            
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                                moveDirection = moveDirection + (cam.CFrame.LookVector * FlySpeed)
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                                moveDirection = moveDirection - (cam.CFrame.LookVector * FlySpeed)
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                                moveDirection = moveDirection + (cam.CFrame.RightVector * FlySpeed)
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                                moveDirection = moveDirection - (cam.CFrame.RightVector * FlySpeed)
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                                moveDirection = moveDirection + Vector3.new(0, FlySpeed, 0)
                            end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                                moveDirection = moveDirection - Vector3.new(0, FlySpeed, 0)
                            end
                            
                            BodyVelocity.Velocity = moveDirection
                        end
                    end))
                end
            end
        else
            local char = LocalPlayer.Character
            if char then
                local flyPart = char:FindFirstChild("CrayxFly")
                if flyPart then
                    flyPart:Destroy()
                end
            end
        end
    end
})

local FlySpeedSlider = MovementSection:Slider({
    Text = "Fly Speed",
    Default = 50,
    Minimum = 1,
    Maximum = 200,
    Callback = function(value)
        FlySpeed = value
    end
})

local NoClipToggle = MovementSection:Toggle({
    Text = "NoClip",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
        
        if NoclipEnabled then
            NoClipConnection = RunService.Stepped:Connect(function()
                if NoclipEnabled and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            table.insert(Connections, NoClipConnection)
        else
            if NoClipConnection then
                NoClipConnection:Disconnect()
                NoClipConnection = nil
            end
        end
    end
})

local InfiniteJumpToggle = MovementSection:Toggle({
    Text = "Infinite Jump",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
        
        if InfiniteJumpEnabled then
            local connection
            connection = UserInputService.JumpRequest:Connect(function()
                if InfiniteJumpEnabled then
                    local char = LocalPlayer.Character
                    if char then
                        local humanoid = char:FindFirstChild("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end
            end)
            table.insert(Connections, connection)
        end
    end
})

-- Player Visuals Section
local VisualsSection = PlayerTab:Section({
    Text = "Visuals"
})

local FullbrightToggle = VisualsSection:Toggle({
    Text = "Fullbright",
    Default = false,
    Callback = function(state)
        if state then
            local lighting = game:GetService("Lighting")
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 2
            lighting.GlobalShadows = false
            lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            local lighting = game:GetService("Lighting")
            lighting.Ambient = Color3.fromRGB(0.5, 0.5, 0.5)
            lighting.Brightness = 1
            lighting.GlobalShadows = true
            lighting.OutdoorAmbient = Color3.fromRGB(0.5, 0.5, 0.5)
        end
    end
})

local XRayToggle = VisualsSection:Toggle({
    Text = "X-Ray",
    Default = false,
    Callback = function(state)
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 1 then
                if state then
                    part.LocalTransparencyModifier = 0.5
                else
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end
})

local ESPToggle = VisualsSection:Toggle({
    Text = "ESP",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
        
        local function createESP(player)
            if player == LocalPlayer then return end
            
            local box = Drawing.new("Square")
            box.Visible = false
            box.Color = Color3.fromRGB(255, 0, 0)
            box.Thickness = 2
            box.Filled = false
            
            local nameLabel = Drawing.new("Text")
            nameLabel.Visible = false
            nameLabel.Color = Color3.fromRGB(255, 255, 255)
            nameLabel.Size = 16
            nameLabel.Center = true
            nameLabel.Outline = true
            
            ESPObjects[player] = {box = box, name = nameLabel}
        end
        
        local function updateESP()
            for player, drawings in pairs(ESPObjects) do
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = player.Character.HumanoidRootPart
                    local position, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        local scaleFactor = 1 / (position.Z * math.tan(math.rad(Workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
                        local width = 4 * scaleFactor
                        local height = 5 * scaleFactor
                        
                        drawings.box.Size = Vector2.new(width, height)
                        drawings.box.Position = Vector2.new(position.X - width / 2, position.Y - height / 2)
                        drawings.box.Visible = ESPEnabled
                        
                        drawings.name.Text = player.Name
                        drawings.name.Position = Vector2.new(position.X, position.Y - height / 2 - 20)
                        drawings.name.Visible = ESPEnabled
                    else
                        drawings.box.Visible = false
                        drawings.name.Visible = false
                    end
                else
                    drawings.box.Visible = false
                    drawings.name.Visible = false
                end
            end
        end
        
        if ESPEnabled then
            -- Create ESP for existing players
            for _, player in pairs(Players:GetPlayers()) do
                createESP(player)
            end
            
            -- Connect player added
            table.insert(Connections, Players.PlayerAdded:Connect(function(player)
                createESP(player)
            end))
            
            -- Connect player removed
            table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
                if ESPObjects[player] then
                    ESPObjects[player].box:Remove()
                    ESPObjects[player].name:Remove()
                    ESPObjects[player] = nil
                end
            end))
            
            -- Update ESP loop
            local espConnection = RunService.RenderStepped:Connect(updateESP)
            table.insert(Connections, espConnection)
        else
            -- Cleanup ESP
            for _, drawings in pairs(ESPObjects) do
                drawings.box:Remove()
                drawings.name:Remove()
            end
            ESPObjects = {}
        end
    end
})

local ChamsToggle = VisualsSection:Toggle({
    Text = "Player Chams",
    Default = false,
    Callback = function(state)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if state then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "CrayxChams"
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.OutlineTransparency = 0
                            highlight.Parent = part
                        else
                            local existing = part:FindFirstChild("CrayxChams")
                            if existing then
                                existing:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
})

-- ================== COMBAT TAB ==================
local CombatSection = CombatTab:Section({
    Text = "Combat"
})

local AimlockToggle = CombatSection:Toggle({
    Text = "Aimlock",
    Default = false,
    Callback = function(state)
        if state then
            local closestPlayer = nil
            local closestDistance = math.huge
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        local distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
            
            if closestPlayer then
                local targetRoot = closestPlayer.Character.HumanoidRootPart
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
                    LocalPlayer.Character.HumanoidRootPart.Position,
                    Vector3.new(targetRoot.Position.X, LocalPlayer.Character.HumanoidRootPart.Position.Y, targetRoot.Position.Z)
                )
            end
        end
    end
})

local HitboxExtenderToggle = CombatTab:Toggle({
    Text = "Hitbox Extender",
    Default = false,
    Callback = function(state)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    if state then
                        humanoidRootPart.Size = Vector3.new(10, 10, 10)
                        humanoidRootPart.Transparency = 0.5
                    else
                        humanoidRootPart.Size = Vector3.new(2, 2, 1)
                        humanoidRootPart.Transparency = 0
                    end
                end
            end
        end
    end
})

local AutoClickerToggle = CombatTab:Toggle({
    Text = "Auto Clicker",
    Default = false,
    Callback = function(state)
        if state then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if AutoClickerToggle:Get() then
                    mouse1click()
                end
            end)
            table.insert(Connections, connection)
        end
    end
})

local ClickTPSlider = CombatTab:Slider({
    Text = "Clicks Per Second",
    Default = 10,
    Minimum = 1,
    Maximum = 100,
    Callback = function(value)
        -- CPS logic would go here
    end
})

-- ================== TELEPORT TAB ==================
local TeleportSection = TeleportTab:Section({
    Text = "Teleport"
})

local PlayersDropdown = TeleportSection:Dropdown({
    Text = "Select Player",
    Options = {},
    Default = "Select Player"
})

-- Populate dropdown with players
local function updatePlayersDropdown()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    PlayersDropdown:UpdateOptions(playerNames)
end

updatePlayersDropdown()

table.insert(Connections, Players.PlayerAdded:Connect(updatePlayersDropdown))
table.insert(Connections, Players.PlayerRemoving:Connect(updatePlayersDropdown))

TeleportSection:Button({
    Text = "Teleport to Player",
    Callback = function()
        local selectedPlayer = PlayersDropdown:Get()
        if selectedPlayer and selectedPlayer ~= "Select Player" then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    LocalPlayer.Character:MoveTo(targetRoot.Position + Vector3.new(0, 5, 0))
                end
            end
        end
    end
})

TeleportSection:Button({
    Text = "Bring Player",
    Callback = function()
        local selectedPlayer = PlayersDropdown:Get()
        if selectedPlayer and selectedPlayer ~= "Select Player" then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if targetRoot and myRoot then
                    targetRoot.CFrame = CFrame.new(myRoot.Position + Vector3.new(0, 0, 5))
                end
            end
        end
    end
})

local LocationsSection = TeleportTab:Section({
    Text = "Saved Locations"
})

local locationBox = LocationsSection:Textbox({
    Text = "Location Name",
    Placeholder = "Enter location name...",
    Default = ""
})

LocationsSection:Button({
    Text = "Save Current Location",
    Callback = function()
        local locationName = locationBox:Get()
        if locationName and locationName ~= "" then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local saved = {
                    name = locationName,
                    position = root.Position,
                    time = os.date("%H:%M:%S")
                }
                -- Save to UI or data store
            end
        end
    end
})

-- ================== MISC TAB ==================
local MiscSection = MiscTab:Section({
    Text = "Miscellaneous"
})

MiscSection:Button({
    Text = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
})

MiscSection:Button({
    Text = "Server Hop",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        
        local function getServers(placeId)
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            local success, result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            
            if success and result.data then
                local servers = {}
                for _, server in pairs(result.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
                return servers
            end
            return {}
        end
        
        local servers = getServers(game.PlaceId)
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
        end
    end
})

MiscSection:Toggle({
    Text = "Anti-AFK",
    Default = true,
    Callback = function(state)
        AntiAFKEnabled = state
        if state then
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if AntiAFKEnabled then
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0,0))
                end
            end)
            table.insert(Connections, connection)
        end
    end
})

MiscSection:Button({
    Text = "Copy Game ID",
    Callback = function()
        setclipboard(tostring(game.PlaceId))
    end
})

MiscSection:Button({
    Text = "Copy Job ID",
    Callback = function()
        setclipboard(game.JobId)
    end
})

MiscSection:Button({
    Text = "Reset Character",
    Callback = function()
        LocalPlayer.Character:BreakJoints()
    end
})

local FunSection = MiscTab:Section({
    Text = "Fun"
})

FunSection:Button({
    Text = "Fling Players",
    Callback = function()
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 5000, 0)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.P = 100000
            bv.Parent = root
            
            task.wait(0.1)
            bv:Destroy()
        end
    end
})

FunSection:Button({
    Text = "Invisible (FE)",
    Callback = function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Transparency = 1
                end
            end
        end
    end
})

-- ================== SETTINGS TAB ==================
local UISection = SettingsTab:Section({
    Text = "UI Settings"
})

UISection:Keybind({
    Text = "UI Toggle Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        Library.Keybind = key
    end
})

UISection:Button({
    Text = "Destroy UI",
    Callback = function()
        Window:Destroy()
        for _, connection in pairs(Connections) do
            if connection then
                connection:Disconnect()
            end
        end
    end
})

UISection:Button({
    Text = "Hide UI",
    Callback = function()
        Window:Hide()
    end
})

UISection:Button({
    Text = "Show UI",
    Callback = function()
        Window:Show()
    end
})

local ConfigSection = SettingsTab:Section({
    Text = "Configuration"
})

ConfigSection:Textbox({
    Text = "Config Name",
    Placeholder = "Enter config name...",
    Default = "Default"
})

ConfigSection:Button({
    Text = "Save Config",
    Callback = function()
        -- Save config logic
    end
})

ConfigSection:Button({
    Text = "Load Config",
    Callback = function()
        -- Load config logic
    end
})

-- ================== INITIALIZATION ==================
-- Anti-AFK setup
if AntiAFKEnabled then
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new(0,0))
end

-- Notify user
Library:Notification({
    Text = "CrayxExecuted v6.6.6 Loaded",
    Duration = 5
})

-- Watermark
Library:Watermark({
    Text = "CrayxExecuted | FPS: " .. math.floor(1/RunService.RenderStepped:Wait()),
    Color = Color3.fromRGB(255, 50, 50)
})

print("[CrayxExecuted] WindUI Script Loaded Successfully")