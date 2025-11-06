-- Coba script test sederhana
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Test UI",
   LoadingTitle = "Testing",
   LoadingSubtitle = "By test",
})

local Tab = Window:CreateTab("Test Tab")

Tab:CreateButton({
   Name = "Test Button",
   Callback = function()
       print("Test button worked!")
   end,
})

Rayfield:Notify({
   Title = "Test",
   Content = "UI is working!",
   Duration = 3
})
