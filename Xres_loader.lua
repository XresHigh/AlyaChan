-- Xres Premium Loader v2.0 - FIXED
-- Paste this in your executor

local XresLoader = {
    Version = "2.0.0",
    GitHubURL = "https://github.com/XresHigh/AlyaChan/blob/main/Xres.lua"
}

print("🚀 Starting Xres Premium Loader v" .. XresLoader.Version)

-- Simple loader without UI first
local function LoadXres()
    local success, err = pcall(function()
        print("📡 Downloading script from GitHub...")
        local scriptContent = game:HttpGet(XresLoader.GitHubURL)
        
        if scriptContent then
            print("⚡ Executing Xres Premium...")
            loadstring(scriptContent)()
            print("✅ Xres Premium loaded successfully!")
        else
            error("❌ Failed to download script")
        end
    end)
    
    if not success then
        warn("❌ Failed to load Xres: " .. err)
        
        -- Try direct execution as fallback
        print("🔄 Trying fallback method...")
        LoadXresDirect()
    end
end

-- Fallback direct load
function LoadXresDirect()
    print("🔄 Loading Xres directly...")
    -- We'll load a simplified version directly
    loadstring(game:HttpGet("https://raw.githubusercontent.com/XresHigh/AlyaChan/main/Xres.lua"))()
end

-- Start loading
LoadXres()    Corner.Parent = LoaderFrame

    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 70, 200)
    Stroke.Thickness = 2
    Stroke.Parent = LoaderFrame

    -- Xres Logo
    local Logo = Instance.new("TextLabel")
    Logo.Size = UDim2.new(1, 0, 0, 60)
    Logo.Position = UDim2.new(0, 0, 0, 20)
    Logo.BackgroundTransparency = 1
    Logo.Text = "🜚 XRES PREMIUM"
    Logo.TextColor3 = Color3.fromRGB(170, 120, 255)
    Logo.TextSize = 24
    Logo.Font = Enum.Font.GothamBlack
    Logo.Parent = LoaderFrame

    -- Version
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Size = UDim2.new(1, 0, 0, 20)
    VersionLabel.Position = UDim2.new(0, 0, 0, 70)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "Version " .. XresLoader.Version
    VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
    VersionLabel.TextSize = 14
    VersionLabel.Font = Enum.Font.GothamBold
    VersionLabel.Parent = LoaderFrame

    -- Loading Text
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Size = UDim2.new(1, 0, 0, 30)
    LoadingText.Position = UDim2.new(0, 0, 0, 100)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = "Loading Main Script..."
    LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadingText.TextSize = 16
    LoadingText.Font = Enum.Font.Gotham
    LoadingText.Parent = LoaderFrame

    -- Progress Bar
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0.8, 0, 0, 6)
    ProgressBar.Position = UDim2.new(0.1, 0, 0, 140)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = LoaderFrame

    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(1, 0)
    ProgressCorner.Parent = ProgressBar

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(100, 70, 200)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBar

    local ProgressFillCorner = Instance.new("UICorner")
    ProgressFillCorner.CornerRadius = UDim.new(1, 0)
    ProgressFillCorner.Parent = ProgressFill

    -- Animate Progress Bar
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(ProgressFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
    tween:Play()

    return {
        Gui = LoaderGui,
        Text = LoadingText,
        Progress = ProgressFill
    }
end

-- Main Loading Function
local function LoadXres()
    local loaderUI = CreateLoaderUI()
    
    -- Update status
    loaderUI.Text.Text = "Connecting to GitHub..."
    wait(1)
    
    local success, err = pcall(function()
        -- Try main URL first
        loaderUI.Text.Text = "Downloading Main Script..."
        local scriptContent = game:HttpGet(XresLoader.GitHubURL)
        
        if scriptContent then
            loaderUI.Text.Text = "Executing Xres Premium..."
            wait(1)
            
            -- Execute main script
            loadstring(scriptContent)()
            
            loaderUI.Text.Text = "✅ Xres Loaded Successfully!"
            loaderUI.Progress.BackgroundColor3 = Color3.fromRGB(80, 255, 140)
        else
            error("Failed to download script")
        end
    end)
    
    -- If failed, try backup
    if not success then
        loaderUI.Text.Text = "⚠️ Trying Backup Source..."
        warn("Main source failed: " .. err)
        
        local backupSuccess = pcall(function()
            local backupContent = game:HttpGet(XresLoader.BackupURL)
            if backupContent then
                loadstring(backupContent)()
                loaderUI.Text.Text = "✅ Xres Loaded (Backup)"
                loaderUI.Progress.BackgroundColor3 = Color3.fromRGB(80, 255, 140)
            end
        end)
        
        if not backupSuccess then
            loaderUI.Text.Text = "❌ Failed to Load Xres"
            loaderUI.Progress.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            warn("Backup source also failed")
        end
    end
    
    -- Auto-close loader after 3 seconds
    wait(3)
    loaderUI.Gui:Destroy()
end

-- Initialize Loader
print("🚀 Xres Premium Loader v" .. XresLoader.Version)
LoadXres()
