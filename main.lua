local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "InfHub V2 | Orion Edition", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "InfHubOrion",
    IntroText = "InfHub Loading..."
})

-- [[ Variables ]] --
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local teleportService = game:GetService("TeleportService")

local noclip = false
local flying = false
local flySpeed = 50
local infJump = false
local antifling = false
local spinbot = false
local ctrl = {f = 0, b = 0, l = 0, r = 0}

-- ==========================================
-- 🏃 MOVEMENT TAB
-- ==========================================
local MoveTab = Window:MakeTab({
	Name = "Movement",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MoveTab:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 500,
	Default = 16,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Speed",
	Callback = function(Value)
		if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
	end    
})

MoveTab:AddSlider({
	Name = "JumpPower",
	Min = 50,
	Max = 500,
	Default = 50,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "Power",
	Callback = function(Value)
		if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.UseJumpPower = true
            player.Character.Humanoid.JumpPower = Value
            player.Character.Humanoid.JumpHeight = Value
        end
	end    
})

MoveTab:AddToggle({
	Name = "Classic Fly (WASD)",
	Default = false,
	Callback = function(Value)
		flying = Value
        local char = player.Character
        if not char then return end
        local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        
        if flying and torso then
            local bg = Instance.new("BodyGyro", torso)
            bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            local bv = Instance.new("BodyVelocity", torso)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            task.spawn(function()
                while flying and torso and torso.Parent do
                    char.Humanoid.PlatformStand = true
                    bv.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (ctrl.f+ctrl.b)) + ((workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - workspace.CurrentCamera.CFrame.p))*flySpeed
                    bg.cframe = workspace.CurrentCamera.CFrame
                    task.wait()
                end
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
                if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
            end)
        end
	end    
})

-- ==========================================
-- 👁️ VISUAL TAB
-- ==========================================
local VisualTab = Window:MakeTab({
	Name = "Visual",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

VisualTab:AddToggle({
	Name = "Player ESP",
	Default = false,
	Callback = function(Value)
		_G.ESP = Value
        task.spawn(function()
            while _G.ESP do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and not p.Character:FindFirstChild("InfHighlight") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "InfHighlight"; h.FillColor = Color3.fromRGB(0, 255, 255)
                    end
                end
                task.wait(1)
            end
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("InfHighlight") then p.Character.InfHighlight:Destroy() end
            end
        end)
	end    
})

-- ==========================================
-- 🌐 SERVER TAB
-- ==========================================
local ServerTab = Window:MakeTab({
	Name = "Server",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

ServerTab:AddButton({
	Name = "Rejoin Server",
	Callback = function()
        teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
  	end    
})

ServerTab:AddButton({
	Name = "Server Hop",
	Callback = function()
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(servers.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                teleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                break
            end
        end
  	end    
})

-- ==========================================
-- 👤 LOCAL PLAYER TAB
-- ==========================================
local LPTab = Window:MakeTab({
	Name = "Local Player",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

LPTab:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = function(Value) noclip = Value end    
})

LPTab:AddToggle({
	Name = "Anti-Fling",
	Default = false,
	Callback = function(Value) antifling = Value end    
})

LPTab:AddButton({
	Name = "Reset Character",
	Callback = function() if player.Character then player.Character:BreakJoints() end end    
})

-- ==========================================
-- 🎭 FUN TAB
-- ==========================================
local FunTab = Window:MakeTab({
	Name = "Fun",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

FunTab:AddToggle({
	Name = "SpinBot",
	Default = false,
	Callback = function(Value) spinbot = Value end    
})

FunTab:AddToggle({
	Name = "Infinite Jump",
	Default = false,
	Callback = function(Value) infJump = Value end    
})

-- [[ Backend Handling ]] --
uis.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.W then ctrl.f = 1 elseif i.KeyCode == Enum.KeyCode.S then ctrl.b = -1
    elseif i.KeyCode == Enum.KeyCode.A then ctrl.l = -1 elseif i.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
end)

uis.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.S then ctrl.f = 0; ctrl.b = 0
    elseif i.KeyCode == Enum.KeyCode.A or i.KeyCode == Enum.KeyCode.D then ctrl.l = 0; ctrl.r = 0 end
end)

runService.Heartbeat:Connect(function()
    if spinbot and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(50), 0)
    end
    if antifling then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character then
                for _, part in pairs(v.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false; part.Velocity = Vector3.new(0,0,0) end
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
    if infJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

OrionLib:Init() -- This is mandatory for Orion!
