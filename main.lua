-- [[ InfHub V2 | 


if not game:IsLoaded() then game.Loaded:Wait() end

-- [[ VARIABLES & SERVICES ]] --
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

-- State Variables
local noclip, flying, antifling = false, false, false
local infiniteJump, spinning = false, false
local spinSpeed = 10
local walkSpeed, jumpPower, flySpeed = 16, 50, 50
local ctrl = {f=0,b=0,l=0,r=0}
local lastctrl = {f=0,b=0,l=0,r=0}
local speed = 0
local spectateTarget, spectateConn = nil, nil

local function getRoot()
    return player.Character and (
        player.Character:FindFirstChild("HumanoidRootPart") or
        player.Character:FindFirstChild("Torso")
    )
end

-- ==========================================
-- 🎨 UI CONSTRUCTION
-- ==========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InfHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player.PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Drop shadow effect
local Shadow = Instance.new("Frame", MainFrame)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 14)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

-- Fix bottom corners of title bar
local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Color3.fromRGB(14,14,18)
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 3

local TitleText = Instance.new("TextLabel")
TitleText.Text = "InfHub V2"
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Position = UDim2.new(0, 14, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255,255,255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 4
TitleText.Parent = TitleBar

local SubText = Instance.new("TextLabel")
SubText.Text = "by Bacon_bybuur1221"
SubText.Size = UDim2.new(0, 200, 1, 0)
SubText.Position = UDim2.new(0, 14, 0, 0)
SubText.BackgroundTransparency = 1
SubText.TextColor3 = Color3.fromRGB(120,120,140)
SubText.Font = Enum.Font.Gotham
SubText.TextSize = 11
SubText.TextXAlignment = Enum.TextXAlignment.Left
SubText.ZIndex = 4
SubText.Parent = TitleBar
-- Offset subtitle below title
SubText.Position = UDim2.new(0, 110, 0, 0)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 5
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "–"
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -66, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 5
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- ==========================================
-- SIDEBAR
-- ==========================================
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 54, 1, -38)
Sidebar.Position = UDim2.new(0, 0, 0, 38)
Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = MainFrame

-- Fix top corners
local SidebarTopFix = Instance.new("Frame", Sidebar)
SidebarTopFix.Size = UDim2.new(1, 0, 0, 10)
SidebarTopFix.BackgroundColor3 = Color3.fromRGB(14,14,18)
SidebarTopFix.BorderSizePixel = 0
SidebarTopFix.ZIndex = 3

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.FillDirection = Enum.FillDirection.Vertical
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 10)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -54, 1, -38)
ContentArea.Position = UDim2.new(0, 54, 0, 38)
ContentArea.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
ContentArea.BorderSizePixel = 0
ContentArea.ZIndex = 2
ContentArea.Parent = MainFrame

-- Divider line between sidebar and content
local Divider = Instance.new("Frame", MainFrame)
Divider.Size = UDim2.new(0, 1, 1, -38)
Divider.Position = UDim2.new(0, 54, 0, 38)
Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Divider.BorderSizePixel = 0
Divider.ZIndex = 4

-- ==========================================
-- UI HELPERS
-- ==========================================

local tabs = {}
local tabButtons = {}
local activeTab = nil
local activeBtn = nil

local function createPanel(name)
    local panel = Instance.new("ScrollingFrame")
    panel.Name = name
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel = 0
    panel.ScrollBarThickness = 3
    panel.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 110)
    panel.CanvasSize = UDim2.new(0, 0, 0, 0)
    panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
    panel.Visible = false
    panel.ZIndex = 3
    panel.Parent = ContentArea

    local layout = Instance.new("UIListLayout", panel)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 0)

    local padding = Instance.new("UIPadding", panel)
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.PaddingTop = UDim.new(0, 10)

    return panel
end

local function selectTab(name)
    for n, panel in pairs(tabs) do
        panel.Visible = (n == name)
    end
    for n, btn in pairs(tabButtons) do
        if n == name then
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
            btn.TextColor3 = Color3.fromRGB(100, 100, 120)
        end
    end
    activeTab = name
end

local function addSidebarBtn(icon, name)
    local btn = Instance.new("TextButton")
    btn.Text = icon
    btn.Size = UDim2.new(0, 42, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    btn.TextColor3 = Color3.fromRGB(100, 100, 120)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BorderSizePixel = 0
    btn.ZIndex = 4
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    -- Tooltip
    local tip = Instance.new("TextLabel", btn)
    tip.Text = name
    tip.Size = UDim2.new(0, 80, 0, 24)
    tip.Position = UDim2.new(1, 6, 0.5, -12)
    tip.BackgroundColor3 = Color3.fromRGB(30,30,40)
    tip.TextColor3 = Color3.fromRGB(220,220,220)
    tip.Font = Enum.Font.Gotham
    tip.TextSize = 11
    tip.BorderSizePixel = 0
    tip.ZIndex = 10
    tip.Visible = false
    Instance.new("UICorner", tip).CornerRadius = UDim.new(0, 5)

    btn.MouseEnter:Connect(function() tip.Visible = true end)
    btn.MouseLeave:Connect(function() tip.Visible = false end)

    btn.MouseButton1Click:Connect(function() selectTab(name) end)
    tabButtons[name] = btn

    tabs[name] = createPanel(name)
    return tabs[name]
end

-- Section header
local function addSection(panel, text)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 3
    lbl.Parent = panel

    local line = Instance.new("Frame", panel)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.BackgroundColor3 = Color3.fromRGB(40,40,55)
    line.BorderSizePixel = 0
    line.ZIndex = 3
end

-- Row item (with right arrow >)
local function addItem(panel, text, sub, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Text = ""
    row.Parent = panel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local margin = Instance.new("UIPadding", row)
    margin.PaddingTop = UDim.new(0, 1)
    margin.PaddingBottom = UDim.new(0, 1)

    local label = Instance.new("TextLabel", row)
    label.Text = text
    label.Size = UDim2.new(1, -40, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    if sub then
        local sublabel = Instance.new("TextLabel", row)
        sublabel.Text = sub
        sublabel.Size = UDim2.new(1, -40, 0, 16)
        sublabel.Position = UDim2.new(0, 10, 0, 24)
        sublabel.BackgroundTransparency = 1
        sublabel.TextColor3 = Color3.fromRGB(100, 100, 120)
        sublabel.Font = Enum.Font.Gotham
        sublabel.TextSize = 11
        sublabel.TextXAlignment = Enum.TextXAlignment.Left
        sublabel.ZIndex = 4
    end

    local arrow = Instance.new("TextLabel", row)
    arrow.Text = "›"
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = Color3.fromRGB(100,100,130)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 18
    arrow.ZIndex = 4

    -- Hover effect
    row.MouseEnter:Connect(function()
        row.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    end)
    row.MouseLeave:Connect(function()
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    end)

    if callback then
        row.MouseButton1Click:Connect(function()
            row.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            task.delay(0.15, function() row.BackgroundColor3 = Color3.fromRGB(22,22,28) end)
            callback()
        end)
    end

    return row
end

-- Toggle row
local function addToggle(panel, text, sub, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = panel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel", row)
    label.Text = text
    label.Size = UDim2.new(1, -70, 0, 22)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    if sub then
        local sublabel = Instance.new("TextLabel", row)
        sublabel.Text = sub
        sublabel.Size = UDim2.new(1, -70, 0, 16)
        sublabel.Position = UDim2.new(0, 10, 0, 24)
        sublabel.BackgroundTransparency = 1
        sublabel.TextColor3 = Color3.fromRGB(100, 100, 120)
        sublabel.Font = Enum.Font.Gotham
        sublabel.TextSize = 11
        sublabel.TextXAlignment = Enum.TextXAlignment.Left
        sublabel.ZIndex = 4
    end

    -- Toggle pill
    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 40, 0, 22)
    pill.Position = UDim2.new(1, -52, 0.5, -11)
    pill.BorderSizePixel = 0
    pill.ZIndex = 4
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 5
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local state = default or false
    local function updateVisual()
        if state then
            pill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
            knob.Position = UDim2.new(0, 20, 0, 2)
        else
            pill.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
            knob.Position = UDim2.new(0, 2, 0, 2)
        end
    end
    updateVisual()

    local pillBtn = Instance.new("TextButton", pill)
    pillBtn.Size = UDim2.new(1,0,1,0)
    pillBtn.BackgroundTransparency = 1
    pillBtn.Text = ""
    pillBtn.ZIndex = 6
    pillBtn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then callback(state) end
    end)

    return row
end

-- Slider row
local function addSlider(panel, text, min, max, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    row.BorderSizePixel = 0
    row.ZIndex = 3
    row.Parent = panel
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel", row)
    label.Text = text
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4

    local valLabel = Instance.new("TextLabel", row)
    valLabel.Text = tostring(default)
    valLabel.Size = UDim2.new(0.25, 0, 0, 20)
    valLabel.Position = UDim2.new(0.75, 0, 0, 5)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Color3.fromRGB(80, 160, 255)
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 13
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.ZIndex = 4

    -- Track
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 34)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    track.BorderSizePixel = 0
    track.ZIndex = 4
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((default-min)/(max-min), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    local trackBtn = Instance.new("TextButton", track)
    trackBtn.Size = UDim2.new(1, 0, 0, 20)
    trackBtn.Position = UDim2.new(0, 0, 0.5, -10)
    trackBtn.BackgroundTransparency = 1
    trackBtn.Text = ""
    trackBtn.ZIndex = 7

    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, 0, 0.5, 0)
        valLabel.Text = tostring(val)
        if callback then callback(val) end
    end

    trackBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(i)
        end
    end)
    uis.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(i)
        end
    end)
    uis.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Notification
local notifQueue = {}
local function notify(title, content)
    local notif = Instance.new("Frame", ScreenGui)
    notif.Size = UDim2.new(0, 240, 0, 56)
    notif.Position = UDim2.new(1, -260, 1, -80 - (#notifQueue * 65))
    notif.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    notif.BorderSizePixel = 0
    notif.ZIndex = 20
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)

    local accent = Instance.new("Frame", notif)
    accent.Size = UDim2.new(0, 3, 1, -10)
    accent.Position = UDim2.new(0, 0, 0, 5)
    accent.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    accent.BorderSizePixel = 0
    accent.ZIndex = 21
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1,0)

    local t = Instance.new("TextLabel", notif)
    t.Text = title
    t.Size = UDim2.new(1,-16,0,20)
    t.Position = UDim2.new(0, 12, 0, 8)
    t.BackgroundTransparency = 1
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 21

    local c = Instance.new("TextLabel", notif)
    c.Text = content
    c.Size = UDim2.new(1,-16,0,18)
    c.Position = UDim2.new(0, 12, 0, 28)
    c.BackgroundTransparency = 1
    c.TextColor3 = Color3.fromRGB(150,150,170)
    c.Font = Enum.Font.Gotham
    c.TextSize = 11
    c.TextXAlignment = Enum.TextXAlignment.Left
    c.ZIndex = 21

    table.insert(notifQueue, notif)
    task.delay(3, function()
        table.remove(notifQueue, table.find(notifQueue, notif) or 1)
        notif:Destroy()
    end)
end

-- ==========================================
-- BUILD TABS
-- ==========================================

-- 🏃 Movement Tab
local movePanel = addSidebarBtn("🏃", "Movement")

addSection(movePanel, "Fly")
addToggle(movePanel, "Fly Enabled", "Float through the map", false, function(v) flying = v end)
addSlider(movePanel, "Fly Speed", 10, 500, 50, function(v) flySpeed = v end)

addSection(movePanel, "Walk")
addSlider(movePanel, "WalkSpeed", 16, 500, 16, function(v) walkSpeed = v end)
addSlider(movePanel, "JumpPower", 50, 500, 50, function(v) jumpPower = v end)
addToggle(movePanel, "Infinite Jump", "Jump forever", false, function(v) infiniteJump = v end)

addSection(movePanel, "Other")
addToggle(movePanel, "No-Clip", "Phase through walls", false, function(v) noclip = v end)
addToggle(movePanel, "Anti-Fling", "Prevent being flung", false, function(v) antifling = v end)
addToggle(movePanel, "Spin Character", "Spin around", false, function(v) spinning = v end)
addSlider(movePanel, "Spin Speed", 1, 50, 10, function(v) spinSpeed = v end)

-- 👁️ Visuals Tab
local visualPanel = addSidebarBtn("👁", "Visuals")

addSection(visualPanel, "Players")
addToggle(visualPanel, "Player ESP", "Highlight all players", false, function(v) _G.Chams = v end)

addSection(visualPanel, "Lighting")
addItem(visualPanel, "Fullbright", "Max brightness", function()
    lighting.Brightness = 2
    lighting.ClockTime = 14
    lighting.GlobalShadows = false
    lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    notify("Visuals", "Fullbright enabled!")
end)
addItem(visualPanel, "Reset Lighting", "Restore defaults", function()
    lighting.Brightness = 1
    lighting.ClockTime = 12
    lighting.GlobalShadows = true
    lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
    notify("Visuals", "Lighting reset!")
end)

-- ⚡ Performance Tab
local perfPanel = addSidebarBtn("⚡", "Performance")

addSection(perfPanel, "FPS")
addItem(perfPanel, "FPS Unlocker", "Remove frame cap", function()
    local ok = pcall(function() setfpscap(9999) end)
    if not ok then pcall(function() syn.setfpscap(9999) end) end
    notify("Performance", "FPS cap removed!")
end)
addItem(perfPanel, "Set FPS to 60", "Standard cap", function()
    pcall(function() setfpscap(60) end)
    pcall(function() syn.setfpscap(60) end)
    notify("Performance", "FPS set to 60")
end)

addSection(perfPanel, "Optimization")
addItem(perfPanel, "Remove Effects", "Disable particles/fire/smoke", function()
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") then v:Destroy() end
    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
    notify("Performance", "Effects removed!")
end)

-- 🎯 Spectate Tab
local specPanel = addSidebarBtn("🎯", "Spectate")

local function stopSpectate()
    if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
    spectateTarget = nil
    camera.CameraType = Enum.CameraType.Custom
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject = hum end
    notify("Spectate", "Stopped spectating")
end

local function startSpectate(targetName)
    local target = game.Players:FindFirstChild(targetName)
    if not target or not target.Character then
        notify("Spectate", "Player not found!")
        return
    end
    stopSpectate()
    spectateTarget = target
    camera.CameraType = Enum.CameraType.Custom
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject = hum end
    spectateConn = runService.RenderStepped:Connect(function()
        if spectateTarget and spectateTarget.Character then
            local h = spectateTarget.Character:FindFirstChildOfClass("Humanoid")
            if h then camera.CameraSubject = h end
        else stopSpectate() end
    end)
    notify("Spectate", "Spectating " .. targetName)
end

addSection(specPanel, "Players")

-- Player list (refreshes on open)
local playerListFrame = Instance.new("Frame", specPanel)
playerListFrame.Size = UDim2.new(1, 0, 0, 0)
playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
playerListFrame.BackgroundTransparency = 1
playerListFrame.BorderSizePixel = 0
playerListFrame.ZIndex = 3

local playerListLayout = Instance.new("UIListLayout", playerListFrame)
playerListLayout.Padding = UDim.new(0, 0)

local function refreshPlayerList()
    for _, c in pairs(playerListFrame:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    local others = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then table.insert(others, p) end
    end
    if #others == 0 then
        local empty = Instance.new("TextLabel", playerListFrame)
        empty.Text = "No other players in server"
        empty.Size = UDim2.new(1, 0, 0, 36)
        empty.BackgroundTransparency = 1
        empty.TextColor3 = Color3.fromRGB(100,100,120)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 12
        empty.ZIndex = 4
    else
        for _, p in pairs(others) do
            local pname = p.Name
            local row = Instance.new("TextButton", playerListFrame)
            row.Size = UDim2.new(1, 0, 0, 44)
            row.BackgroundColor3 = Color3.fromRGB(22,22,28)
            row.BorderSizePixel = 0
            row.Text = ""
            row.ZIndex = 3
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

            local nameL = Instance.new("TextLabel", row)
            nameL.Text = pname
            nameL.Size = UDim2.new(1,-50,0,22)
            nameL.Position = UDim2.new(0,10,0,6)
            nameL.BackgroundTransparency = 1
            nameL.TextColor3 = Color3.fromRGB(220,220,240)
            nameL.Font = Enum.Font.Gotham
            nameL.TextSize = 13
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.ZIndex = 4

            local specBtn = Instance.new("TextButton", row)
            specBtn.Text = "👁"
            specBtn.Size = UDim2.new(0,32,0,32)
            specBtn.Position = UDim2.new(1,-40,0.5,-16)
            specBtn.BackgroundColor3 = Color3.fromRGB(40,80,160)
            specBtn.TextColor3 = Color3.new(1,1,1)
            specBtn.Font = Enum.Font.Gotham
            specBtn.TextSize = 16
            specBtn.BorderSizePixel = 0
            specBtn.ZIndex = 5
            Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0,6)
            specBtn.MouseButton1Click:Connect(function() startSpectate(pname) end)

            row.MouseEnter:Connect(function() row.BackgroundColor3 = Color3.fromRGB(30,30,38) end)
            row.MouseLeave:Connect(function() row.BackgroundColor3 = Color3.fromRGB(22,22,28) end)
        end
    end
end

addItem(specPanel, "Refresh Player List", "Update list", function() refreshPlayerList() end)
addItem(specPanel, "Stop Spectating", "Return to own camera", function() stopSpectate() end)
addItem(specPanel, "Next Player", "Cycle through players", function()
    local others = {}
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then table.insert(others, p) end
    end
    if #others == 0 then notify("Spectate", "No other players!"); return end
    local idx = 1
    if spectateTarget then
        for i, p in pairs(others) do
            if p == spectateTarget then idx = i % #others + 1; break end
        end
    end
    startSpectate(others[idx].Name)
end)

refreshPlayerList()

-- 🌍 Server Tab
local serverPanel = addSidebarBtn("🌍", "Server")

addSection(serverPanel, "Travel")
addItem(serverPanel, "Server Hop", "Join a different server", function()
    local Http = game:GetService("HttpService")
    local ok, Raw = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    if not ok then notify("Server", "HttpGet failed!"); return end
    local Servers = Http:JSONDecode(Raw)
    for _, v in pairs(Servers.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            teleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
            return
        end
    end
    notify("Server", "No available servers!")
end)
addItem(serverPanel, "Rejoin Server", "Reconnect to this server", function()
    teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

-- ☁️ Sky Tab
local skyPanel = addSidebarBtn("☁", "Sky")

addSection(skyPanel, "Time")
addSlider(skyPanel, "Time of Day", 0, 24, 12, function(v) lighting.ClockTime = v end)

addSection(skyPanel, "Skybox")
addItem(skyPanel, "Galaxy Skybox", "Apply galaxy theme", function()
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    local s = Instance.new("Sky", lighting)
    s.SkyboxBk = "rbxassetid://159454299"
    s.SkyboxDn = "rbxassetid://159454296"
    s.SkyboxFt = "rbxassetid://159454293"
    s.SkyboxLf = "rbxassetid://159454286"
    s.SkyboxRt = "rbxassetid://159454300"
    s.SkyboxUp = "rbxassetid://159454289"
    notify("Sky", "Galaxy skybox applied!")
end)
addItem(skyPanel, "Remove Custom Sky", "Reset to default sky", function()
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("Sky") then v:Destroy() end
    end
    notify("Sky", "Sky reset!")
end)

-- Default to first tab
selectTab("Movement")

-- ==========================================
-- TOGGLE BUTTON (Menu key or GUI button)
-- ==========================================
local MenuBtn = Instance.new("TextButton", ScreenGui)
MenuBtn.Text = "☰  InfHub"
MenuBtn.Size = UDim2.new(0, 100, 0, 34)
-- Positioned bottom-left to avoid Roblox top-left logo/buttons
MenuBtn.Position = UDim2.new(0, 12, 1, -120)
MenuBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MenuBtn.TextColor3 = Color3.fromRGB(220,220,255)
MenuBtn.Font = Enum.Font.GothamBold
MenuBtn.TextSize = 13
MenuBtn.BorderSizePixel = 0
MenuBtn.ZIndex = 15
MenuBtn.Active = true
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(0, 8)

-- Accent line on left of button
local btnAccent = Instance.new("Frame", MenuBtn)
btnAccent.Size = UDim2.new(0, 3, 0.7, 0)
btnAccent.Position = UDim2.new(0, 0, 0.15, 0)
btnAccent.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
btnAccent.BorderSizePixel = 0
btnAccent.ZIndex = 16
Instance.new("UICorner", btnAccent).CornerRadius = UDim.new(1, 0)

-- Drag logic for MenuBtn
local menuDragging = false
local menuDragStart, menuStartPos

MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = true
        menuDragStart = input.Position
        menuStartPos = MenuBtn.Position
    end
end)

MenuBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = false
    end
end)

uis.InputChanged:Connect(function(input)
    if menuDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - menuDragStart
        -- Only move if dragged more than 5px (to allow clicks)
        if delta.Magnitude > 5 then
            MenuBtn.Position = UDim2.new(
                menuStartPos.X.Scale,
                menuStartPos.X.Offset + delta.X,
                menuStartPos.Y.Scale,
                menuStartPos.Y.Offset + delta.Y
            )
        end
    end
end)

local menuBtnMoved = false
MenuBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuBtnMoved = false
        menuDragStart = input.Position
    end
end)

uis.InputChanged:Connect(function(input)
    if menuDragging and input.Position and menuDragStart then
        if (input.Position - menuDragStart).Magnitude > 5 then
            menuBtnMoved = true
        end
    end
end)

MenuBtn.MouseButton1Click:Connect(function()
    if not menuBtnMoved then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Keybind: RightShift to toggle
uis.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Minimize logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentArea.Visible = not minimized
    Sidebar.Visible = not minimized
    Divider.Visible = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 520, 0, 38)
        MinBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 520, 0, 380)
        MinBtn.Text = "–"
    end
end)

-- Show on load
MainFrame.Visible = true

-- ==========================================
-- 📱 MOBILE FLY BUTTONS
-- ==========================================
local mobileUp, mobileDown = false, false
local mobileForward, mobileBack, mobileLeft, mobileRight = false, false, false, false

if isMobile then
    local sg = Instance.new("ScreenGui", player.PlayerGui)
    sg.Name = "MobileFlyControls"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true

    local function makeBtn(text, pos, onDown, onUp)
        local btn = Instance.new("TextButton", sg)
        btn.Size = UDim2.new(0, 65, 0, 65)
        btn.Position = pos
        btn.Text = text
        btn.BackgroundColor3 = Color3.fromRGB(18,18,28)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 20
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        btn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then onDown() end
        end)
        btn.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then onUp() end
        end)
    end

    makeBtn("⬆", UDim2.new(0, 80, 1, -220), function() mobileForward=true end, function() mobileForward=false end)
    makeBtn("⬇", UDim2.new(0, 80, 1, -145), function() mobileBack=true end,    function() mobileBack=false end)
    makeBtn("⬅", UDim2.new(0, 5,  1, -183), function() mobileLeft=true end,    function() mobileLeft=false end)
    makeBtn("➡", UDim2.new(0, 155,1, -183), function() mobileRight=true end,   function() mobileRight=false end)
    makeBtn("🔼", UDim2.new(1,-80, 1, -220), function() mobileUp=true end,     function() mobileUp=false end)
    makeBtn("🔽", UDim2.new(1,-80, 1, -145), function() mobileDown=true end,   function() mobileDown=false end)

    runService.RenderStepped:Connect(function() sg.Enabled = flying end)
end

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
            bg.Name = "FlyGyro"; bg.P = 9e4; bg.maxTorque = Vector3.new(9e9,9e9,9e9)
            local bv = root:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", root)
            bv.Name = "FlyVelocity"; bv.maxForce = Vector3.new(9e9,9e9,9e9)
            hum.PlatformStand = true

            ctrl.f = (uis:IsKeyDown(Enum.KeyCode.W) or mobileForward) and 1 or 0
            ctrl.b = (uis:IsKeyDown(Enum.KeyCode.S) or mobileBack)    and -1 or 0
            ctrl.l = (uis:IsKeyDown(Enum.KeyCode.A) or mobileLeft)    and -1 or 0
            ctrl.r = (uis:IsKeyDown(Enum.KeyCode.D) or mobileRight)   and 1 or 0

            local altBoost = 0
            if uis:IsKeyDown(Enum.KeyCode.Space) or mobileUp   then altBoost =  flySpeed end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) or mobileDown then altBoost = -flySpeed end

            local moving = ctrl.l+ctrl.r ~= 0 or ctrl.f+ctrl.b ~= 0 or altBoost ~= 0
            speed = moving and math.min(speed + 0.5 + speed/flySpeed, flySpeed) or math.max(speed-1, 0)

            local fwd  = camera.CFrame.lookVector * (ctrl.f+ctrl.b)
            local side = (camera.CFrame * CFrame.new(ctrl.l+ctrl.r, 0, 0)).p - camera.CFrame.p
            local alt  = Vector3.new(0, altBoost / math.max(flySpeed,1), 0)
            local dir  = fwd + side + alt

            if moving and dir.Magnitude > 0 then
                bv.velocity = dir.Unit * speed
                lastctrl = {f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
            elseif speed ~= 0 then
                local ldir = camera.CFrame.lookVector*(lastctrl.f+lastctrl.b) + (camera.CFrame*CFrame.new(lastctrl.l+lastctrl.r,0,0)).p - camera.CFrame.p
                bv.velocity = ldir.Magnitude>0 and ldir.Unit*speed or Vector3.new(0,0.1,0)
            else
                bv.velocity = Vector3.new(0, 0.1, 0)
            end
            bg.cframe = camera.CFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*40*speed/math.max(flySpeed,1)),0,0)
        else
            if root then
                if root:FindFirstChild("FlyGyro")    then root.FlyGyro:Destroy()    end
                if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
            end
            if hum then hum.PlatformStand = false end
        end
    end
end)

runService.RenderStepped:Connect(function()
    if player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum and not flying then
            hum.WalkSpeed = walkSpeed
            hum.JumpPower = jumpPower
            hum.UseJumpPower = true
        end
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
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                            part.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end
            end
        end
        if spinning then
            local root = getRoot()
            if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
        end
    end
end)

uis.JumpRequest:Connect(function()
    if infiniteJump and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

mouse.Button1Down:Connect(function()
    if uis:IsKeyDown(Enum.KeyCode.LeftControl) and player.Character then
        player.Character:SetPrimaryPartCFrame(CFrame.new(mouse.Hit.p + Vector3.new(0,3,0)))
    end
end)

task.spawn(function()
    while task.wait(1) do
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character then
                if _G.Chams and not p.Character:FindFirstChild("InfHighlight") then
                    Instance.new("Highlight", p.Character).Name = "InfHighlight"
                elseif not _G.Chams and p.Character:FindFirstChild("InfHighlight") then
                    p.Character.InfHighlight:Destroy()
                end
            end
        end
    end
end)

notify("InfHub V2", "RedzHub style loaded! Press RightShift to toggle.")
