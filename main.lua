local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "InfHub V2 | Public Utility",
    LoadingTitle = "InfHub Loading...",
    LoadingSubtitle = "By Bacon_bybuur1221",
    Theme = "AmberGlow",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false -- Key System Removed
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
local antifling = false
local autoClicking = false

-- Classic Fly Logic Variables
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local speed = 0

-- ==========================================
-- MOVEMENT TAB
-- ==========================================
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
       if player.Character:FindFirstChild("Humanoid") then 
           player.Character.Humanoid.WalkSpeed = v 
       end 
   end,
})

MoveTab:CreateSlider({
   Name = "JumpPower / Height",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Callback = function(v) 
       if player.Character:FindFirstChild("Humanoid") then 
           player.Character.Humanoid.UseJumpPower = true
           player.Character.Humanoid.JumpPower = v 
           player.Character.Humanoid.JumpHeight = v
       end 
   end,
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
-- FLIGHT TAB
-- ==========================================
local FlyTab = Window:CreateTab("Flight", 4483362458)

FlyTab:CreateToggle({
   Name = "Classic Exploit Fly",
   CurrentValue = false,
   Callback = function(Value)
        flying = Value
        local char = player.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        
        if flying and torso and hum then
            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = torso.CFrame
            
            local bv = Instance.new("BodyVelocity", torso)
            bv.velocity = Vector3.new(0,0.1,0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            task.spawn(function()
                while flying and torso and torso.Parent do
                    hum.PlatformStand = true
                    if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                        speed = speed + .5 + (speed / flySpeed)
                        if speed > flySpeed then speed = flySpeed end
                    elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                        speed = speed - 1
                        if speed < 0 then speed = 0 end
                    end
                    
                    if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                        bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*speed
                        lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                    elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                        bv.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - workspace.CurrentCamera.CoordinateFrame.p))*speed
                    else
                        bv.velocity = Vector3.new(0,0.1,0)
                    end
                    bg.cframe = workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/flySpeed),0,0)
                    task.wait()
                end
                speed = 0
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
                if hum then hum.PlatformStand = false end
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
-- PLAYER & VISUALS TAB
-- ==========================================
local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateToggle({
   Name = "Anti-Fling",
   CurrentValue = false,
   Callback = function(v) antifling = v end,
})

PlayerTab:CreateToggle({
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

PlayerTab:CreateButton({
   Name = "Reset Character",
   Callback = function() player.Character:BreakJoints() end,
})

-- ==========================================
-- UTILITY TAB
-- ==========================================
local UtilTab = Window:CreateTab("Utility", 4483362458)

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

-- [[ LOOPS & INPUT HANDLERS ]] --

uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
end)

uis.InputEnded:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then ctrl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then ctrl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
end)

runService.Heartbeat:Connect(function()
    if antifling then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character then
                for _, part in pairs(v.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Velocity = Vector3.new(0,0,0)
                        part.RotVelocity = Vector3.new(0,0,0)
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

Rayfield:Notify({Title = "InfHub V2", Content = "Loaded! Welcome, " .. player.Name})
