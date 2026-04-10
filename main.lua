local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "InfHub V2 | Ultimate Utility",
    LoadingTitle = "InfHub Loading...",
    LoadingSubtitle = "By Bacon_bybuur1221",
    Theme = "AmberGlow",
    ConfigurationSaving = { Enabled = true, FolderName = "InfHub_Configs", FileName = "InfHub" },
    KeySystem = true, 
    KeySettings = {
        Title = "Infhub Key",
        Subtitle = "Key System",
        Note = "Key: best hub",
        FileName = "InfhubKey",
        SaveKey = true,
        Key = {"best hub"}
    }
})

-- [[ Variables ]] --
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local teleportService = game:GetService("TeleportService")

local noclip = false
local flying = false
local flySpeed = 50
local infJump = false
local spinbot = false
local antifling = false
local clickTP = false
local autoClicking = false

-- ==========================================
-- MOVEMENT TAB
-- ==========================================
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = v end end,
})

MoveTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(v) infJump = v end,
})

MoveTab:CreateToggle({
   Name = "No-Clip",
   CurrentValue = false,
   Callback = function(v) noclip = v end,
})

-- ==========================================
-- PLAYER TAB
-- ==========================================
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateToggle({
   Name = "Freeze Character",
   CurrentValue = false,
   Callback = function(Value)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = Value
        end
   end,
})

PlayerTab:CreateToggle({
   Name = "Anti-Fling",
   CurrentValue = false,
   Callback = function(Value) antifling = Value end,
})

PlayerTab:CreateButton({
   Name = "Reset Character",
   Callback = function() player.Character:BreakJoints() end,
})

-- ==========================================
-- FLIGHT TAB
-- ==========================================
local FlyTab = Window:CreateTab("Flight", 4483362458)

FlyTab:CreateToggle({
   Name = "Power Fly (WASD)",
   CurrentValue = false,
   Callback = function(Value)
        flying = Value
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if flying and hrp then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "InfFlyVel"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            local bg = Instance.new("BodyGyro", hrp)
            bg.Name = "InfFlyGyro"
            bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bg.P = 9000
            task.spawn(function()
                while flying and hrp and hrp.Parent do
                    bv.Velocity = workspace.CurrentCamera.CFrame:VectorToWorldSpace(player.Character.Humanoid.MoveDirection) * flySpeed
                    bg.CFrame = workspace.CurrentCamera.CFrame
                    task.wait()
                end
                bv:Destroy() bg:Destroy()
            end)
        end
   end,
})

FlyTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 500},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(v) flySpeed = v end,
})

-- ==========================================
-- VISUALS TAB
-- ==========================================
local VisualTab = Window:CreateTab("Visuals", 4483362458)

VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Callback = function(Value)
        _G.ESP = Value
        task.spawn(function()
            while _G.ESP do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and not p.Character:FindFirstChild("InfHighlight") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "InfHighlight"
                        h.FillColor = Color3.fromRGB(255, 165, 0)
                    end
                end
                task.wait(1)
            end
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("InfHighlight") then p.Character.InfHighlight:Destroy() end
            end
        end)
   end,
})

VisualTab:CreateButton({
   Name = "Fullbright",
   Callback = function()
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.GlobalShadows = false
   end,
})

-- ==========================================
-- UTILITY & FUN TAB
-- ==========================================
local UtilTab = Window:CreateTab("Utility/Fun", 4483362458)

UtilTab:CreateToggle({
   Name = "Click TP (Ctrl + Click)",
   CurrentValue = false,
   Callback = function(v) clickTP = v end,
})

UtilTab:CreateToggle({
   Name = "SpinBot",
   CurrentValue = false,
   Callback = function(v) spinbot = v end,
})

UtilTab:CreateToggle({
   Name = "Auto-Clicker",
   CurrentValue = false,
   Callback = function(Value)
        autoClicking = Value
        task.spawn(function()
            while autoClicking do
                task.wait(0.01)
                if mouse1click then mouse1click() end
            end
        end)
   end,
})

UtilTab:CreateButton({
   Name = "Anti-AFK",
   Callback = function()
        player.Idled:Connect(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
   end,
})

-- ==========================================
-- SERVER TAB
-- ==========================================
local ServerTab = Window:CreateTab("Server", 4483362458)

ServerTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                teleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
   end,
})

-- [[ CORE LOOPS ]] --

runService.Heartbeat:Connect(function()
    if spinbot and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end
    
    if antifling then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character then
                for _, part in pairs(v.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Velocity = Vector3.new(0,0,0)
                    end
                end
            end
        end
    end
end)

runService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

uis.JumpRequest:Connect(function()
    if infJump and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

mouse.Button1Down:Connect(function()
    if clickTP and uis:IsKeyDown(Enum.KeyCode.LeftControl) then
        if player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = mouse.Hit * CFrame.new(0, 3, 0)
        end
    end
end)

Rayfield:Notify({Title = "InfHub V2", Content = "Full Script Loaded Successfully!"})
