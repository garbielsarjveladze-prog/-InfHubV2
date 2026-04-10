-- [[ InfHub V2 | Master Public Edition ]] --
-- Update: Restored Sky Tab + Fly starts DISABLED.

if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "InfHub V2 | Master Public",
    LoadingTitle = "InfHub V2",
    LoadingSubtitle = "By Bacon_bybuur1221",
    Theme = "AmberGlow",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false 
})

-- [[ VARIABLES & SERVICES ]] --
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")

-- State Variables
local noclip, flying, antifling = false, false, false 
local walkSpeed, jumpPower, flySpeed = 16, 50, 50
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local speed = 0

-- Helper to find Character Root
local function getRoot()
    return player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso"))
end

-- ==========================================
-- 🏃 MOVEMENT TAB
-- ==========================================
local MoveTab = Window:CreateTab("Movement", 4483362458)

MoveTab:CreateToggle({
    Name = "Fly Enabled",
    CurrentValue = false, 
    Callback = function(v) flying = v end,
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) flySpeed = v end,
})

MoveTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) walkSpeed = v end,
})

MoveTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) jumpPower = v end,
})

MoveTab:CreateToggle({
    Name = "No-Clip",
    CurrentValue = false,
    Callback = function(v) noclip = v end,
})

MoveTab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Callback = function(v) antifling = v end,
})

-- ==========================================
-- 👁️ VISUALS TAB
-- ==========================================
local VisualTab = Window:CreateTab("Visuals", 4483362458)

VisualTab:CreateToggle({
    Name = "Player Chams (ESP)",
    CurrentValue = false,
    Callback = function(v) _G.Chams = v end,
})

VisualTab:CreateButton({
    Name = "Fullbright",
    Callback = function()
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.GlobalShadows = false
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end,
})

-- ==========================================
-- 🌍 SERVER TAB
-- ==========================================
local ServerTab = Window:CreateTab("Server", 4483362458)

ServerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local Api = "https://games.roblox.com/v1/games/"
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
        local Raw = game:HttpGet(_servers)
        local Servers = Http:JSONDecode(Raw)
        for i,v in pairs(Servers.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                teleportService:TeleportToPlaceInstance(_place, v.id, player)
            end
        end
    end,
})

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end,
})

-- ==========================================
-- ☁️ SKY TAB
-- ==========================================
local SkyTab = Window:CreateTab("Sky", 4483362458)

SkyTab:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 0.1,
    CurrentValue = 12,
    Callback = function(v) lighting.ClockTime = v end,
})

SkyTab:CreateButton({
    Name = "Galaxy Skybox",
    Callback = function()
        local s = Instance.new("Sky", lighting)
        s.SkyboxBk, s.SkyboxDn, s.SkyboxFt, s.SkyboxLf, s.SkyboxRt, s.SkyboxUp = 
            "rbxassetid://159454299", "rbxassetid://159454296", "rbxassetid://159454293", 
            "rbxassetid://159454286", "rbxassetid://159454300", "rbxassetid://159454289"
    end,
})

-- ==========================================
-- ⚙️ CORE ENGINE
-- ==========================================

task.spawn(function()
    while true do
        task.wait()
        local root = getRoot()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

        if flying and root and hum then
            local bg = root:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", root)
            bg.Name = "FlyGyro"; bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            
            local bv = root:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", root)
            bv.Name = "FlyVelocity"; bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

            hum.PlatformStand = true

            ctrl.f = uis:IsKeyDown(Enum.KeyCode.W) and 1 or 0
            ctrl.b = uis:IsKeyDown(Enum.KeyCode.S) and -1 or 0
            ctrl.l = uis:IsKeyDown(Enum.KeyCode.A) and -1 or 0
            ctrl.r = uis:IsKeyDown(Enum.KeyCode.D) and 1 or 0

            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = speed + 0.5 + (speed / flySpeed)
                if speed > flySpeed then speed = flySpeed end
            else
                speed = speed - 1
                if speed < 0 then speed = 0 end
            end

            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.velocity = ((camera.CFrame.lookVector * (ctrl.f + ctrl.b)) + ((camera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - camera.CFrame.p)) * speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif speed ~= 0 then
                bv.velocity = ((camera.CFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((camera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - camera.CFrame.p)) * speed
            else
                bv.velocity = Vector3.new(0, 0.1, 0)
            end
            bg.cframe = camera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / flySpeed), 0, 0)
        else
            if root then
                if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
                if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
            end
            if hum then hum.PlatformStand = false end
        end
    end
end)

runService.RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") and not flying then
        player.Character.Humanoid.WalkSpeed = walkSpeed
        player.Character.Humanoid.JumpPower = jumpPower
        player.Character.Humanoid.UseJumpPower = true
    end
end)

runService.Stepped:Connect(function()
    if player.Character then
        if noclip then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        if antifling then
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character then
                    for _, part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false; part.Velocity = Vector3.new(0,0,0) end
                    end
                end
            end
        end
    end
end)

mouse.Button1Down:Connect(function()
    if uis:IsKeyDown(Enum.KeyCode.LeftControl) and player.Character then
        player.Character:SetPrimaryPartCFrame(CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0)))
    end
end)

task.spawn(function()
    while task.wait(1) do
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                if _G.Chams and not p.Character:FindFirstChild("InfHighlight") then
                    Instance.new("Highlight", p.Character).Name = "InfHighlight"
                elseif not _G.Chams and p.Character:FindFirstChild("InfHighlight") then
                    if p.Character:FindFirstChild("InfHighlight") then p.Character.InfHighlight:Destroy() end
                end
            end
        end
    end
end)

Rayfield:Notify({Title = "InfHub V2", Content = "Full Script Loaded (Sky Restored!)"})
