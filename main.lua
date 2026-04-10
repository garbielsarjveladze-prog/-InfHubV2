local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "InfHub",
    Icon = 0, 
    LoadingTitle = "Loading InfHub",
    LoadingSubtitle = "By Bacon_bybuur1221",
    Theme = "AmberGlow",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "InfHub_Configs", 
       FileName = "InfHub"
    },
    KeySystem = true,
    KeySettings = {
       Title = "Infhub Key",
       Subtitle = "Key System",
       Note = "The key is: best hub",
       FileName = "InfhubKey",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = {"best hub"}
    }
})

-- Variables
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local noclip = false
local flying = false
local flySpeed = 50
local ws_val = 16
local jp_val = 50

-- Handle Respawning (keeps speed/jump after death)
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = ws_val
    hum.JumpPower = jp_val
    hum.UseJumpPower = true
end)

-- ==========================================
-- MOVEMENT TAB
-- ==========================================
local MainTab = Window:CreateTab("Movement", 4483362458)
MainTab:CreateSection("Character Modifiers")

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
        ws_val = Value
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
   end,
})

MainTab:CreateSlider({
   Name = "JumpHeight",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Callback = function(Value)
        jp_val = Value
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.UseJumpPower = true
            player.Character.Humanoid.JumpPower = Value
        end
   end,
})

MainTab:CreateToggle({
   Name = "No-Clip",
   CurrentValue = false,
   Callback = function(Value) noclip = Value end,
})

-- ==========================================
-- TELEPORT TAB
-- ==========================================
local TPTab = Window:CreateTab("Teleport", 4483362458)
TPTab:CreateSection("Player Teleportation")

TPTab:CreateInput({
   Name = "TP to Player",
   PlaceholderText = "Exact Username",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
        local target = game.Players:FindFirstChild(Text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Teleport", Content = "Successfully teleported to " .. Text, Duration = 3})
        else
            Rayfield:Notify({Title = "Error", Content = "Player not found!", Duration = 3})
        end
   end,
})

-- ==========================================
-- FLY TAB
-- ==========================================
local FlyTab = Window:CreateTab("Fly", 4483362458)
FlyTab:CreateSection("Flight Controls")

FlyTab:CreateToggle({
   Name = "Enable Fly",
   CurrentValue = false,
   Callback = function(Value)
        flying = Value
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if flying and hrp then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.Parent = hrp
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            
            local bg = Instance.new("BodyGyro")
            bg.Name = "FlyGyro"
            bg.Parent = hrp
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            
            task.spawn(function()
                while flying do
                    bv.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * flySpeed
                    bg.CFrame = game.Workspace.CurrentCamera.CFrame
                    task.wait()
                end
                bv:Destroy()
                bg:Destroy()
            end)
        end
   end,
})

FlyTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 500},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Callback = function(Value) flySpeed = Value end,
})

-- ==========================================
-- LOOPS
-- ==========================================
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

Rayfield:Notify({
   Title = "InfHub Loaded",
   Content = "Welcome back, Bacon_bybuur1221!",
   Duration = 5,
   Image = 4483362458,
})
