-- [[ Safety: Wait for game to load ]] --
if not game:IsLoaded() then game.Loaded:Wait() end

-- [[ Load Redz Library ]] --
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/666-pax/RedzLib/main/Source.lua"))()

-- [[ Create Main Window ]] --
local Window = Library:MakeWindow({
  Name = "InfHub V2 | Redz Edition",
  HidePremium = false,
  SaveConfig = true,
  ConfigFolder = "InfHubV2"
})

-- [[ Global Variables ]] --
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

-- [[ TABS & CATEGORIES ]] --
local MoveTab = Window:MakeTab({"Movement", "rbxassetid://10734950309"})
local VisualTab = Window:MakeTab({"Visual", "rbxassetid://10734983210"})
local ServerTab = Window:MakeTab({"Server", "rbxassetid://10734949169"})
local FunTab = Window:MakeTab({"Fun", "rbxassetid://10734925614"})
local LPTab = Window:MakeTab({"Local Player", "rbxassetid://10734944545"})

-- ==========================================
-- 🏃 MOVEMENT SECTION
-- ==========================================
MoveTab:AddSlider({
  Name = "Walk Speed",
  Min = 16, Max = 500, Default = 16,
  Callback = function(v) 
    if player.Character and player.Character:FindFirstChild("Humanoid") then 
        player.Character.Humanoid.WalkSpeed = v 
    end 
  end
})

MoveTab:AddSlider({
  Name = "Jump Power",
  Min = 50, Max = 500, Default = 50,
  Callback = function(v) 
    if player.Character and player.Character:FindFirstChild("Humanoid") then 
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = v 
        player.Character.Humanoid.JumpHeight = v
    end 
  end
})

MoveTab:AddToggle({
  Name = "Classic Fly (WASD)",
  Default = false,
  Callback = function(v) 
    flying = v 
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
-- 👁️ VISUAL SECTION
-- ==========================================
VisualTab:AddToggle({
  Name = "Player ESP",
  Default = false,
  Callback = function(v)
      _G.ESP = v
      task.spawn(function()
          while _G.ESP do
              for _, p in pairs(game.Players:GetPlayers()) do
                  if p ~= player and p.Character and not p.Character:FindFirstChild("InfHighlight") then
                      local h = Instance.new("Highlight", p.Character)
                      h.Name = "InfHighlight"; h.FillColor = Color3.fromRGB(255, 0, 0)
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

VisualTab:AddButton({
  Name = "Fullbright",
  Callback = function()
      game.Lighting.Brightness = 2
      game.Lighting.ClockTime = 14
      game.Lighting.GlobalShadows = false
  end
})

-- ==========================================
-- 🌐 SERVER SECTION
-- ==========================================
ServerTab:AddButton({
  Name = "Rejoin Server",
  Callback = function() teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end
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
-- 🎭 FUN SECTION
-- ==========================================
FunTab:AddToggle({
  Name = "SpinBot",
  Default = false,
  Callback = function(v) spinbot = v end
})

FunTab:AddToggle({
  Name = "Infinite Jump",
  Default = false,
  Callback = function(v) infJump = v end
})

-- ==========================================
-- 👤 LOCAL PLAYER SECTION
-- ==========================================
LPTab:AddToggle({
  Name = "Freeze Character",
  Default = false,
  Callback = function(v) 
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then 
        player.Character.HumanoidRootPart.Anchored = v 
    end
  end
})

LPTab:AddToggle({
  Name = "No-Clip",
  Default = false,
  Callback = function(v) noclip = v end
})

LPTab:AddToggle({
  Name = "Anti-Fling",
  Default = false,
  Callback = function(v) antifling = v end
})

LPTab:AddButton({
  Name = "Reset Character",
  Callback = function() if player.Character then player.Character:BreakJoints() end end
})

-- [[ BACKEND SYSTEM LOGIC ]] --

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

-- [[ Finished Loading ]] --
Library:Notify({
    Title = "InfHub V2",
    Content = "Successfully loaded Redz Edition!",
    Duration = 5
})
