
if not game:IsLoaded() then game.Loaded:Wait() end

-- ============================================================
-- SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UIS             = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local Lighting        = game:GetService("Lighting")
local SoundService    = game:GetService("SoundService")

local player   = Players.LocalPlayer
local mouse    = player:GetMouse()
local camera   = workspace.CurrentCamera
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ============================================================
-- CLICK SOUND
-- ============================================================
local clickSound = Instance.new("Sound", SoundService)
clickSound.SoundId  = "rbxassetid://6895079853"
clickSound.Volume   = 0.3
local function playClick() pcall(function() clickSound:Play() end) end

-- ============================================================
-- UI SIZE CONFIG
-- ============================================================
local UI_SIZES = {
    small  = {w=400, h=330, sb=46, font=11, title=12},
    medium = {w=520, h=390, sb=54, font=13, title=14},
    large  = {w=640, h=460, sb=62, font=14, title=15},
}
local currentSize = isMobile and "small" or "medium"
local function sz() return UI_SIZES[currentSize] end

-- ============================================================
-- STATE VARIABLES
-- ============================================================
local noclip        = false
local flying        = false
local antifling     = false
local infiniteJump  = false
local spinning      = false
local spinSpeed     = 10
local bhop          = false
local godMode       = false
local autoRespawn   = false
local antiAFK       = false
local noRecoil      = false
local silentAim     = false
local aimbot        = false
local fovChanger    = false
local fovValue      = 70
local fullbright    = false
local clickTP       = false
local walkSpeed     = 16
local jumpPower     = 50
local flySpeed      = 50

-- ESP flags
local playerESP     = false
local nameESP       = false
local boxESP        = false
local tracers       = false
local chams         = false
local xray          = false
local bossESP       = false

-- Fly internals
local ctrl          = {f=0,b=0,l=0,r=0}
local lastctrl      = {f=0,b=0,l=0,r=0}
local flySpeedVal   = 0

-- Spectate
local spectateTarget, spectateConn = nil, nil

-- Mobile fly
local mUp,mDown,mFwd,mBwd,mLeft,mRight = false,false,false,false,false,false

-- ============================================================
-- HELPERS
-- ============================================================
local function getRoot()
    return player.Character and (
        player.Character:FindFirstChild("HumanoidRootPart") or
        player.Character:FindFirstChild("Torso"))
end
local function getHum()
    return player.Character and player.Character:FindFirstChildOfClass("Humanoid")
end
local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play(); return tween
end

-- ============================================================
-- SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "InfHubV2"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = player.PlayerGui

-- ============================================================
-- MAIN FRAME
-- ============================================================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size            = UDim2.new(0, sz().w, 0, sz().h)
MainFrame.Position        = UDim2.new(0.5, -sz().w/2, 0.5, -sz().h/2)
MainFrame.BackgroundColor3= Color3.fromRGB(13,13,18)
MainFrame.BorderSizePixel = 0
MainFrame.Active          = true
MainFrame.Draggable       = true
MainFrame.ClipsDescendants= true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)

-- Glow
local Glow = Instance.new("ImageLabel", ScreenGui)
Glow.Image              = "rbxassetid://936008661"
Glow.ImageColor3        = Color3.fromRGB(35,90,210)
Glow.ImageTransparency  = 0.72
Glow.BackgroundTransparency = 1
Glow.ZIndex             = 0
Glow.ScaleType          = Enum.ScaleType.Slice
Glow.SliceCenter        = Rect.new(24,24,276,276)
local function updateGlow()
    local s=sz()
    Glow.Size     = UDim2.new(0,s.w+60,0,s.h+60)
    Glow.Position = UDim2.new(0.5,-(s.w+60)/2, 0.5,-(s.h+60)/2)
end
updateGlow()

-- Animated top accent bar
local AccentBar = Instance.new("Frame", MainFrame)
AccentBar.Size            = UDim2.new(1,0,0,2)
AccentBar.BackgroundColor3= Color3.fromRGB(50,130,255)
AccentBar.BorderSizePixel = 0
AccentBar.ZIndex          = 10
local AccGrad = Instance.new("UIGradient", AccentBar)
AccGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(40,80,255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(110,200,255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(40,80,255)),
}
task.spawn(function()
    local t=0
    while true do RunService.RenderStepped:Wait(); t=t+0.007; AccGrad.Offset=Vector2.new(math.sin(t),0) end
end)

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size            = UDim2.new(1,0,0,42)
TitleBar.Position        = UDim2.new(0,0,0,2)
TitleBar.BackgroundColor3= Color3.fromRGB(9,9,14)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex          = 5
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)
-- fix bottom corners
local TFix = Instance.new("Frame", TitleBar)
TFix.Size=UDim2.new(1,0,0.5,0); TFix.Position=UDim2.new(0,0,0.5,0)
TFix.BackgroundColor3=Color3.fromRGB(9,9,14); TFix.BorderSizePixel=0; TFix.ZIndex=5

-- Animated pulsing dot
local Dot = Instance.new("Frame", TitleBar)
Dot.Size             = UDim2.new(0,7,0,7)
Dot.Position         = UDim2.new(0,12,0.5,-3.5)
Dot.BackgroundColor3 = Color3.fromRGB(50,140,255)
Dot.BorderSizePixel  = 0
Dot.ZIndex           = 7
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)
task.spawn(function()
    while true do
        tw(Dot,{BackgroundColor3=Color3.fromRGB(110,210,255)},0.9,Enum.EasingStyle.Sine)
        task.wait(0.9)
        tw(Dot,{BackgroundColor3=Color3.fromRGB(25,70,190)},0.9,Enum.EasingStyle.Sine)
        task.wait(0.9)
    end
end)

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Text="InfHub V2"; TitleLbl.Size=UDim2.new(0,130,1,0); TitleLbl.Position=UDim2.new(0,24,0,0)
TitleLbl.BackgroundTransparency=1; TitleLbl.TextColor3=Color3.fromRGB(230,230,255)
TitleLbl.Font=Enum.Font.GothamBold; TitleLbl.TextSize=sz().title
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left; TitleLbl.ZIndex=7

local SubLbl = Instance.new("TextLabel", TitleBar)
SubLbl.Text="Master Public"; SubLbl.Size=UDim2.new(0,150,1,0); SubLbl.Position=UDim2.new(0,102,0,0)
SubLbl.BackgroundTransparency=1; SubLbl.TextColor3=Color3.fromRGB(50,130,255)
SubLbl.Font=Enum.Font.Gotham; SubLbl.TextSize=sz().font
SubLbl.TextXAlignment=Enum.TextXAlignment.Left; SubLbl.ZIndex=7

-- ── S / M / L size buttons ──────────────────────────────────
local SzFrame = Instance.new("Frame", TitleBar)
SzFrame.Size=UDim2.new(0,84,0,26); SzFrame.Position=UDim2.new(0,265,0.5,-13)
SzFrame.BackgroundColor3=Color3.fromRGB(18,18,28); SzFrame.BorderSizePixel=0; SzFrame.ZIndex=7
Instance.new("UICorner",SzFrame).CornerRadius=UDim.new(0,6)
local SzLayout=Instance.new("UIListLayout",SzFrame)
SzLayout.FillDirection=Enum.FillDirection.Horizontal; SzLayout.Padding=UDim.new(0,2)
Instance.new("UIPadding",SzFrame).PaddingLeft=UDim.new(0,3)
Instance.new("UIPadding",SzFrame).PaddingTop=UDim.new(0,3)

local szBtns={}
for _,label in pairs({"S","M","L"}) do
    local b=Instance.new("TextButton",SzFrame)
    b.Text=label; b.Size=UDim2.new(0,24,0,20)
    b.BackgroundColor3=Color3.fromRGB(28,28,42)
    b.TextColor3=Color3.fromRGB(170,170,210)
    b.Font=Enum.Font.GothamBold; b.TextSize=10; b.BorderSizePixel=0; b.ZIndex=8
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
    szBtns[label]=b
    b.MouseButton1Click:Connect(function()
        playClick()
        currentSize = label=="S" and "small" or label=="M" and "medium" or "large"
        local s=sz()
        tw(MainFrame,{Size=UDim2.new(0,s.w,0,s.h), Position=UDim2.new(0.5,-s.w/2,0.5,-s.h/2)},0.32,Enum.EasingStyle.Back)
        tw(Glow,{Size=UDim2.new(0,s.w+60,0,s.h+60), Position=UDim2.new(0.5,-(s.w+60)/2,0.5,-(s.h+60)/2)},0.32)
        TitleLbl.TextSize=s.title; SubLbl.TextSize=s.font
        for _,btn2 in pairs(szBtns) do tw(btn2,{BackgroundColor3=Color3.fromRGB(28,28,42)},0.1) end
        tw(b,{BackgroundColor3=Color3.fromRGB(45,100,210)},0.1)
    end)
end
local defLabel = isMobile and "S" or "M"
tw(szBtns[defLabel],{BackgroundColor3=Color3.fromRGB(45,100,210)},0.01)

-- Close button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Text="✕"; CloseBtn.Size=UDim2.new(0,26,0,26); CloseBtn.Position=UDim2.new(1,-32,0.5,-13)
CloseBtn.BackgroundColor3=Color3.fromRGB(190,50,50); CloseBtn.TextColor3=Color3.new(1,1,1)
CloseBtn.Font=Enum.Font.GothamBold; CloseBtn.TextSize=12; CloseBtn.BorderSizePixel=0; CloseBtn.ZIndex=8
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function()
    playClick()
    local s=sz()
    tw(MainFrame,{Size=UDim2.new(0,s.w,0,0)},0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    task.wait(0.2); MainFrame.Visible=false
    MainFrame.Size=UDim2.new(0,s.w,0,s.h)
end)

-- Minimize button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Text="–"; MinBtn.Size=UDim2.new(0,26,0,26); MinBtn.Position=UDim2.new(1,-62,0.5,-13)
MinBtn.BackgroundColor3=Color3.fromRGB(40,40,60); MinBtn.TextColor3=Color3.new(1,1,1)
MinBtn.Font=Enum.Font.GothamBold; MinBtn.TextSize=15; MinBtn.BorderSizePixel=0; MinBtn.ZIndex=8
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,6)

-- ============================================================
-- SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.BackgroundColor3=Color3.fromRGB(9,9,14); Sidebar.BorderSizePixel=0; Sidebar.ZIndex=4
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,10)
local SFix=Instance.new("Frame",Sidebar); SFix.BackgroundColor3=Color3.fromRGB(9,9,14); SFix.BorderSizePixel=0; SFix.ZIndex=4
local SBLayout=Instance.new("UIListLayout",Sidebar)
SBLayout.FillDirection=Enum.FillDirection.Vertical; SBLayout.Padding=UDim.new(0,3); SBLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
local SBPad=Instance.new("UIPadding",Sidebar); SBPad.PaddingTop=UDim.new(0,10)

local Divider=Instance.new("Frame",MainFrame)
Divider.BackgroundColor3=Color3.fromRGB(22,22,35); Divider.BorderSizePixel=0; Divider.ZIndex=5

local ContentArea=Instance.new("Frame",MainFrame)
ContentArea.BackgroundColor3=Color3.fromRGB(13,13,18); ContentArea.BorderSizePixel=0; ContentArea.ZIndex=3
ContentArea.ClipsDescendants=true

local function refreshLayout()
    local s=sz()
    Sidebar.Size=UDim2.new(0,s.sb,1,-44); Sidebar.Position=UDim2.new(0,0,0,44)
    SFix.Size=UDim2.new(1,0,0,12)
    Divider.Size=UDim2.new(0,1,1,-44); Divider.Position=UDim2.new(0,s.sb,0,44)
    ContentArea.Size=UDim2.new(1,-s.sb,1,-44); ContentArea.Position=UDim2.new(0,s.sb,0,44)
end
refreshLayout()

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local panels={} ; local tabBtns={}; local activeTab=nil

local function makePanel(name)
    local sf=Instance.new("ScrollingFrame",ContentArea)
    sf.Name=name; sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=2; sf.ScrollBarImageColor3=Color3.fromRGB(45,45,75)
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Visible=false; sf.ZIndex=4
    local l=Instance.new("UIListLayout",sf); l.Padding=UDim.new(0,1)
    local p=Instance.new("UIPadding",sf)
    p.PaddingLeft=UDim.new(0,8); p.PaddingRight=UDim.new(0,8); p.PaddingTop=UDim.new(0,6)
    return sf
end

local function selectTab(name)
    for n,p in pairs(panels) do
        if n==name then
            p.Visible=true
            p.Position=UDim2.new(-0.06,0,0,0)
            tw(p,{Position=UDim2.new(0,0,0,0)},0.16,Enum.EasingStyle.Quad)
        else p.Visible=false end
    end
    for n,b in pairs(tabBtns) do
        if n==name then
            tw(b,{BackgroundColor3=Color3.fromRGB(25,50,105)},0.14)
            b.TextColor3=Color3.fromRGB(255,255,255)
        else
            tw(b,{BackgroundColor3=Color3.fromRGB(9,9,14)},0.14)
            b.TextColor3=Color3.fromRGB(75,75,105)
        end
    end
    activeTab=name
end

local function addTab(icon,name)
    local s=sz()
    local b=Instance.new("TextButton",Sidebar)
    b.Text=icon; b.Size=UDim2.new(0,s.sb-10,0,s.sb-10)
    b.BackgroundColor3=Color3.fromRGB(9,9,14); b.TextColor3=Color3.fromRGB(75,75,105)
    b.Font=Enum.Font.GothamBold; b.TextSize=18; b.BorderSizePixel=0; b.ZIndex=5
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    -- tooltip
    local tip=Instance.new("TextLabel",b)
    tip.Text=name; tip.Size=UDim2.new(0,92,0,25); tip.Position=UDim2.new(1,5,0.5,-12)
    tip.BackgroundColor3=Color3.fromRGB(16,16,26); tip.TextColor3=Color3.fromRGB(200,200,230)
    tip.Font=Enum.Font.Gotham; tip.TextSize=11; tip.BorderSizePixel=0; tip.ZIndex=12; tip.Visible=false
    Instance.new("UICorner",tip).CornerRadius=UDim.new(0,5)
    b.MouseEnter:Connect(function() tip.Visible=true; if activeTab~=name then tw(b,{BackgroundColor3=Color3.fromRGB(18,18,30)},0.08) end end)
    b.MouseLeave:Connect(function() tip.Visible=false; if activeTab~=name then tw(b,{BackgroundColor3=Color3.fromRGB(9,9,14)},0.08) end end)
    b.MouseButton1Click:Connect(function()
        playClick()
        tw(b,{BackgroundColor3=Color3.fromRGB(38,75,170)},0.07)
        task.delay(0.08,function() if activeTab~=name then tw(b,{BackgroundColor3=Color3.fromRGB(25,50,105)},0.1) end end)
        selectTab(name)
    end)
    tabBtns[name]=b; panels[name]=makePanel(name)
    return panels[name]
end

-- ============================================================
-- WIDGET BUILDERS
-- ============================================================
local function section(panel,text)
    local f=Instance.new("Frame",panel); f.Size=UDim2.new(1,0,0,26); f.BackgroundTransparency=1; f.BorderSizePixel=0; f.ZIndex=4
    local l=Instance.new("TextLabel",f); l.Text=text:upper()
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(50,130,255)
    l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
    local line=Instance.new("Frame",panel); line.Size=UDim2.new(1,0,0,1); line.BackgroundColor3=Color3.fromRGB(20,20,34); line.BorderSizePixel=0; line.ZIndex=4
end

local function addToggle(panel,text,sub,default,cb)
    local row=Instance.new("Frame",panel)
    row.Size=UDim2.new(1,0,0,44); row.BackgroundColor3=Color3.fromRGB(17,17,24); row.BorderSizePixel=0; row.ZIndex=4
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.Text=text
    lbl.Size=UDim2.new(1,-65,0,22); lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(215,215,240)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=sz().font; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    if sub then
        local sl=Instance.new("TextLabel",row); sl.Text=sub
        sl.Size=UDim2.new(1,-65,0,16); sl.Position=UDim2.new(0,10,0,24)
        sl.BackgroundTransparency=1; sl.TextColor3=Color3.fromRGB(75,75,105)
        sl.Font=Enum.Font.Gotham; sl.TextSize=9; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=5
    end
    local pill=Instance.new("Frame",row)
    pill.Size=UDim2.new(0,42,0,22); pill.Position=UDim2.new(1,-52,0.5,-11)
    pill.BorderSizePixel=0; pill.ZIndex=5
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,2,0,2)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=6
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=default or false
    local function refresh(anim)
        if state then
            if anim then tw(pill,{BackgroundColor3=Color3.fromRGB(45,145,255)},0.14) else pill.BackgroundColor3=Color3.fromRGB(45,145,255) end
            tw(knob,{Position=UDim2.new(0,22,0,2)},0.14,Enum.EasingStyle.Back)
        else
            if anim then tw(pill,{BackgroundColor3=Color3.fromRGB(36,36,55)},0.14) else pill.BackgroundColor3=Color3.fromRGB(36,36,55) end
            tw(knob,{Position=UDim2.new(0,2,0,2)},0.14,Enum.EasingStyle.Back)
        end
    end
    refresh(false)
    local pb=Instance.new("TextButton",pill); pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1; pb.Text=""; pb.ZIndex=7
    pb.MouseButton1Click:Connect(function()
        playClick(); state=not state; refresh(true)
        tw(row,{BackgroundColor3=state and Color3.fromRGB(20,42,70) or Color3.fromRGB(17,17,24)},0.1)
        task.delay(0.22,function() tw(row,{BackgroundColor3=Color3.fromRGB(17,17,24)},0.14) end)
        if cb then cb(state) end
    end)
    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(22,22,32)},0.08) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(17,17,24)},0.08) end)
end

local function addSlider(panel,text,min,max,default,cb)
    local row=Instance.new("Frame",panel)
    row.Size=UDim2.new(1,0,0,54); row.BackgroundColor3=Color3.fromRGB(17,17,24); row.BorderSizePixel=0; row.ZIndex=4
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.Text=text
    lbl.Size=UDim2.new(0.68,0,0,20); lbl.Position=UDim2.new(0,10,0,5)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(210,210,240)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=sz().font; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local valLbl=Instance.new("TextLabel",row); valLbl.Text=tostring(default)
    valLbl.Size=UDim2.new(0.3,0,0,20); valLbl.Position=UDim2.new(0.7,0,0,5)
    valLbl.BackgroundTransparency=1; valLbl.TextColor3=Color3.fromRGB(50,150,255)
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=sz().font; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=5
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-18,0,5); track.Position=UDim2.new(0,9,0,38)
    track.BackgroundColor3=Color3.fromRGB(28,28,44); track.BorderSizePixel=0; track.ZIndex=5
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(45,140,255); fill.BorderSizePixel=0; fill.ZIndex=6
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,13,0,13); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=7
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local dragging=false
    local tb=Instance.new("TextButton",track); tb.Size=UDim2.new(1,0,0,22); tb.Position=UDim2.new(0,0,0.5,-11); tb.BackgroundTransparency=1; tb.Text=""; tb.ZIndex=8
    local function upd(input)
        local pos=math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local v=math.floor(min+(max-min)*pos)
        fill.Size=UDim2.new(pos,0,1,0); knob.Position=UDim2.new(pos,0,0.5,0); valLbl.Text=tostring(v)
        if cb then cb(v) end
    end
    tb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; upd(i) end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(22,22,32)},0.08) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(17,17,24)},0.08) end)
end

local function addButton(panel,text,sub,cb)
    local row=Instance.new("TextButton",panel)
    row.Size=UDim2.new(1,0,0,44); row.BackgroundColor3=Color3.fromRGB(17,17,24); row.BorderSizePixel=0; row.Text=""; row.ZIndex=4
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.Text=text
    lbl.Size=UDim2.new(1,-36,0,22); lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(215,215,240)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=sz().font; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    if sub then
        local sl=Instance.new("TextLabel",row); sl.Text=sub
        sl.Size=UDim2.new(1,-36,0,16); sl.Position=UDim2.new(0,10,0,24)
        sl.BackgroundTransparency=1; sl.TextColor3=Color3.fromRGB(72,72,105)
        sl.Font=Enum.Font.Gotham; sl.TextSize=9; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=5
    end
    local arrow=Instance.new("TextLabel",row); arrow.Text="›"
    arrow.Size=UDim2.new(0,20,1,0); arrow.Position=UDim2.new(1,-22,0,0)
    arrow.BackgroundTransparency=1; arrow.TextColor3=Color3.fromRGB(55,55,95)
    arrow.Font=Enum.Font.GothamBold; arrow.TextSize=18; arrow.ZIndex=5
    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(22,22,34)},0.08); tw(arrow,{TextColor3=Color3.fromRGB(50,150,255)},0.08) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(17,17,24)},0.08); tw(arrow,{TextColor3=Color3.fromRGB(55,55,95)},0.08) end)
    row.MouseButton1Click:Connect(function()
        playClick()
        tw(row,{BackgroundColor3=Color3.fromRGB(30,55,115)},0.07)
        task.delay(0.18,function() tw(row,{BackgroundColor3=Color3.fromRGB(17,17,24)},0.14) end)
        if cb then cb() end
    end)
end

local function addDropdown(panel,text,options,default,cb)
    local row=Instance.new("Frame",panel)
    row.Size=UDim2.new(1,0,0,44); row.BackgroundColor3=Color3.fromRGB(17,17,24); row.BorderSizePixel=0; row.ZIndex=4
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.Text=text
    lbl.Size=UDim2.new(0.48,0,1,0); lbl.Position=UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency=1; lbl.TextColor3=Color3.fromRGB(200,200,235)
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=sz().font; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local selected=default or (options[1] or "")
    local vBtn=Instance.new("TextButton",row)
    vBtn.Text=selected.." ▾"; vBtn.Size=UDim2.new(0.48,0,0,28); vBtn.Position=UDim2.new(0.51,0,0.5,-14)
    vBtn.BackgroundColor3=Color3.fromRGB(24,24,38); vBtn.TextColor3=Color3.fromRGB(180,180,220)
    vBtn.Font=Enum.Font.Gotham; vBtn.TextSize=10; vBtn.BorderSizePixel=0; vBtn.ZIndex=6
    Instance.new("UICorner",vBtn).CornerRadius=UDim.new(0,5)
    local open=false; local dropF=nil
    vBtn.MouseButton1Click:Connect(function()
        playClick(); open=not open
        if dropF then dropF:Destroy(); dropF=nil end
        if open then
            dropF=Instance.new("Frame",ScreenGui)
            dropF.Size=UDim2.new(0,160,0,math.min(#options,8)*28+8)
            local ap=vBtn.AbsolutePosition
            dropF.Position=UDim2.new(0,ap.X,0,ap.Y+18); dropF.BackgroundColor3=Color3.fromRGB(18,18,30); dropF.BorderSizePixel=0; dropF.ZIndex=55
            Instance.new("UICorner",dropF).CornerRadius=UDim.new(0,8)
            tw(dropF,{Position=UDim2.new(0,ap.X,0,ap.Y+32)},0.14,Enum.EasingStyle.Back)
            local dl=Instance.new("UIListLayout",dropF); dl.Padding=UDim.new(0,2)
            local dp=Instance.new("UIPadding",dropF); dp.PaddingTop=UDim.new(0,4); dp.PaddingLeft=UDim.new(0,4); dp.PaddingRight=UDim.new(0,4)
            for _,opt in pairs(options) do
                local ob=Instance.new("TextButton",dropF)
                ob.Text=opt; ob.Size=UDim2.new(1,0,0,24)
                ob.BackgroundColor3=Color3.fromRGB(24,24,40); ob.TextColor3=Color3.fromRGB(185,185,225)
                ob.Font=Enum.Font.Gotham; ob.TextSize=10; ob.BorderSizePixel=0; ob.ZIndex=56
                Instance.new("UICorner",ob).CornerRadius=UDim.new(0,4)
                ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(34,34,56)},0.07) end)
                ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=Color3.fromRGB(24,24,40)},0.07) end)
                ob.MouseButton1Click:Connect(function()
                    playClick(); selected=opt; vBtn.Text=opt.." ▾"
                    open=false; dropF:Destroy(); dropF=nil
                    if cb then cb(opt) end
                end)
            end
        end
    end)
    row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(22,22,32)},0.08) end)
    row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=Color3.fromRGB(17,17,24)},0.08) end)
end

-- Notification
local notifList={}
local function notify(title,msg,col)
    local n=Instance.new("Frame",ScreenGui)
    n.Size=UDim2.new(0,228,0,58); n.ZIndex=60; n.BorderSizePixel=0
    n.BackgroundColor3=Color3.fromRGB(14,14,22)
    local baseY=-72-(#notifList*66)
    n.Position=UDim2.new(1,20,1,baseY)
    Instance.new("UICorner",n).CornerRadius=UDim.new(0,8)
    local acc=Instance.new("Frame",n); acc.Size=UDim2.new(0,3,0.74,0); acc.Position=UDim2.new(0,0,0.13,0)
    acc.BackgroundColor3=col or Color3.fromRGB(45,140,255); acc.BorderSizePixel=0; acc.ZIndex=61
    Instance.new("UICorner",acc).CornerRadius=UDim.new(1,0)
    local t=Instance.new("TextLabel",n); t.Text=title; t.Size=UDim2.new(1,-14,0,22); t.Position=UDim2.new(0,12,0,5)
    t.BackgroundTransparency=1; t.TextColor3=Color3.fromRGB(255,255,255); t.Font=Enum.Font.GothamBold; t.TextSize=12; t.TextXAlignment=Enum.TextXAlignment.Left; t.ZIndex=62
    local m=Instance.new("TextLabel",n); m.Text=msg; m.Size=UDim2.new(1,-14,0,18); m.Position=UDim2.new(0,12,0,30)
    m.BackgroundTransparency=1; m.TextColor3=Color3.fromRGB(125,125,155); m.Font=Enum.Font.Gotham; m.TextSize=10; m.TextXAlignment=Enum.TextXAlignment.Left; m.ZIndex=62
    table.insert(notifList,n)
    tw(n,{Position=UDim2.new(1,-238,1,baseY)},0.28,Enum.EasingStyle.Back)
    task.delay(3.5,function()
        tw(n,{Position=UDim2.new(1,20,1,baseY)},0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        task.wait(0.25)
        local idx=table.find(notifList,n); if idx then table.remove(notifList,idx) end
        n:Destroy()
    end)
end

-- ============================================================
-- BUILD TABS
-- ============================================================

-- 🏃 MOVEMENT TAB
local movePanel = addTab("🏃","Movement")
section(movePanel,"Speed")
addSlider(movePanel,"WalkSpeed",16,500,16,function(v) walkSpeed=v end)
addSlider(movePanel,"JumpPower",50,500,50,function(v) jumpPower=v end)
addToggle(movePanel,"Infinite Jump","Jump forever in air",false,function(v) infiniteJump=v end)
addToggle(movePanel,"Bhop","Bunny hop on ground",false,function(v) bhop=v end)
section(movePanel,"Fly")
addToggle(movePanel,"Fly Enabled",nil,false,function(v) flying=v end)
addSlider(movePanel,"Fly Speed",10,500,50,function(v) flySpeed=v end)
section(movePanel,"Other")
addToggle(movePanel,"No-Clip","Phase through walls",false,function(v) noclip=v end)
addToggle(movePanel,"Anti-Fling","Prevent being launched",false,function(v) antifling=v end)
addToggle(movePanel,"Spinbot","Spin your character",false,function(v) spinning=v end)
addSlider(movePanel,"Spin Speed",1,50,10,function(v) spinSpeed=v end)
addToggle(movePanel,"God Mode","Infinite health",false,function(v) godMode=v; if v then notify("Movement","God Mode ON",Color3.fromRGB(255,200,60)) end end)

-- 👁️ ESP TAB
local espPanel = addTab("👁","ESP")
section(espPanel,"Players")
addToggle(espPanel,"Player ESP","Highlight all players",false,function(v) playerESP=v end)
addToggle(espPanel,"Name ESP","Show name + distance",false,function(v) nameESP=v end)
addToggle(espPanel,"Box ESP","Outline selection box",false,function(v) boxESP=v end)
addToggle(espPanel,"Tracers","Tracer outline on player",false,function(v) tracers=v end)
addToggle(espPanel,"Chams","Red fill highlight",false,function(v) chams=v end)
addToggle(espPanel,"X-Ray","See through walls",false,function(v) xray=v end)
section(espPanel,"World")
addToggle(espPanel,"Boss ESP","Highlight high-HP entities",false,function(v) bossESP=v end)
section(espPanel,"Visuals")
addToggle(espPanel,"Fullbright","Max map brightness",false,function(v)
    fullbright=v
    if not v then Lighting.Brightness=1; Lighting.ClockTime=12; Lighting.GlobalShadows=true; Lighting.OutdoorAmbient=Color3.fromRGB(70,70,70) end
end)
addToggle(espPanel,"FOV Changer",nil,false,function(v) fovChanger=v; if not v then camera.FieldOfView=70 end end)
addSlider(espPanel,"FOV Value",30,120,70,function(v) fovValue=v end)

-- 🎯 COMBAT TAB
local combatPanel = addTab("🎯","Combat")
section(combatPanel,"Aim")
addToggle(combatPanel,"Aimbot","Lock camera to nearest player",false,function(v) aimbot=v end)
addToggle(combatPanel,"Silent Aim","Hit targets without visible aim",false,function(v) silentAim=v end)
addToggle(combatPanel,"No Recoil","Lock camera on fire",false,function(v) noRecoil=v end)

-- 🌍 TELEPORT TAB
local tpPanel = addTab("🌍","Teleport")
section(tpPanel,"Teleport")
addToggle(tpPanel,"Click TP","Ctrl+Click to teleport",false,function(v) clickTP=v end)
addButton(tpPanel,"Teleport to Mouse","TP to cursor position now",function()
    local root=getRoot()
    if root then root.CFrame=CFrame.new(mouse.Hit.p+Vector3.new(0,5,0)); notify("Teleport","Moved to cursor!") end
end)

-- 🎯 SPECTATE TAB
local specPanel = addTab("🔍","Spectate")

local function stopSpectate()
    if spectateConn then spectateConn:Disconnect(); spectateConn=nil end
    spectateTarget=nil
    camera.CameraType=Enum.CameraType.Custom
    local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject=hum end
    notify("Spectate","Stopped")
end

local function startSpectate(targetName)
    local target=Players:FindFirstChild(targetName)
    if not target or not target.Character then notify("Spectate","Player not found!",Color3.fromRGB(255,80,80)); return end
    stopSpectate(); spectateTarget=target
    camera.CameraType=Enum.CameraType.Custom
    local hum=target.Character:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject=hum end
    spectateConn=RunService.RenderStepped:Connect(function()
        if spectateTarget and spectateTarget.Character then
            local h=spectateTarget.Character:FindFirstChildOfClass("Humanoid")
            if h then camera.CameraSubject=h end
        else stopSpectate() end
    end)
    notify("Spectate","Watching "..targetName)
end

local function getOthers()
    local t={}
    for _,p in pairs(Players:GetPlayers()) do if p~=player then table.insert(t,p.Name) end end
    if #t==0 then t={"(empty)"} end
    return t
end

section(specPanel,"Players")
addDropdown(specPanel,"Select Player",getOthers(),"",function(v) _G.specTarget=v end)
addButton(specPanel,"Start Spectating",nil,function()
    if _G.specTarget and _G.specTarget~="(empty)" then startSpectate(_G.specTarget)
    else notify("Spectate","Pick a player first!",Color3.fromRGB(255,140,60)) end
end)
addButton(specPanel,"Stop Spectating",nil,function() stopSpectate() end)
addButton(specPanel,"Next Player (Cycle)",nil,function()
    local others={}
    for _,p in pairs(Players:GetPlayers()) do if p~=player then table.insert(others,p) end end
    if #others==0 then notify("Spectate","No other players!"); return end
    local idx=1
    if spectateTarget then for i,p in pairs(others) do if p==spectateTarget then idx=i%#others+1; break end end end
    startSpectate(others[idx].Name)
end)

-- 🌍 SERVER TAB
local serverPanel = addTab("🌐","Server")
section(serverPanel,"Travel")
addButton(serverPanel,"Server Hop","Join different server",function()
    local ok,raw=pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") end)
    if not ok then notify("Server","Request failed",Color3.fromRGB(255,80,80)); return end
    local data=HttpService:JSONDecode(raw)
    for _,v in pairs(data.data) do
        if v.playing<v.maxPlayers and v.id~=game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId,v.id,player); return end
    end
    notify("Server","No open servers found",Color3.fromRGB(255,160,60))
end)
addButton(serverPanel,"Rejoin",nil,function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,player) end)

-- ☁️ SKY TAB
local skyPanel = addTab("☁","Sky")
section(skyPanel,"Time")
addSlider(skyPanel,"Time of Day",0,24,12,function(v) Lighting.ClockTime=v end)
section(skyPanel,"Skybox")
addButton(skyPanel,"Galaxy Skybox",nil,function()
    for _,v in pairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
    local s=Instance.new("Sky",Lighting)
    s.SkyboxBk="rbxassetid://159454299"; s.SkyboxDn="rbxassetid://159454296"
    s.SkyboxFt="rbxassetid://159454293"; s.SkyboxLf="rbxassetid://159454286"
    s.SkyboxRt="rbxassetid://159454300"; s.SkyboxUp="rbxassetid://159454289"
    notify("Sky","Galaxy skybox applied!")
end)
addButton(skyPanel,"Remove Sky",nil,function()
    for _,v in pairs(Lighting:GetChildren()) do if v:IsA("Sky") then v:Destroy() end end
    notify("Sky","Sky reset!")
end)
addButton(skyPanel,"Reset Lighting",nil,function()
    Lighting.Brightness=1; Lighting.ClockTime=12; Lighting.GlobalShadows=true; Lighting.OutdoorAmbient=Color3.fromRGB(70,70,70)
    notify("Sky","Lighting reset!")
end)

-- ⚡ PERFORMANCE TAB
local perfPanel = addTab("⚡","Performance")
section(perfPanel,"FPS")
addButton(perfPanel,"FPS Unlocker","Remove frame cap",function()
    pcall(function() setfpscap(9999) end); pcall(function() syn.setfpscap(9999) end)
    notify("Performance","FPS cap removed!")
end)
addButton(perfPanel,"Cap to 60 FPS",nil,function()
    pcall(function() setfpscap(60) end); pcall(function() syn.setfpscap(60) end)
    notify("Performance","FPS set to 60")
end)
section(perfPanel,"Optimization")
addButton(perfPanel,"Remove All Effects","Disable particles/fire/smoke",function()
    for _,v in pairs(Lighting:GetChildren()) do if v:IsA("PostEffect") then v:Destroy() end end
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then v.Enabled=false end
    end
    notify("Performance","Effects removed!")
end)

-- ⚙️ MISC TAB
local miscPanel = addTab("⚙","Misc")
section(miscPanel,"Player")
addToggle(miscPanel,"Anti-AFK","Prevent auto-disconnect",false,function(v)
    antiAFK=v; if v then notify("Misc","Anti-AFK enabled!",Color3.fromRGB(80,220,120)) end
end)
addToggle(miscPanel,"Auto Respawn","Respawn on death",false,function(v) autoRespawn=v end)

-- default
selectTab("Movement")

-- ============================================================
-- MINIMIZE
-- ============================================================
local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    playClick(); minimized=not minimized
    ContentArea.Visible=not minimized; Sidebar.Visible=not minimized; Divider.Visible=not minimized
    local s=sz()
    if minimized then tw(MainFrame,{Size=UDim2.new(0,s.w,0,44)},0.18,Enum.EasingStyle.Quad); MinBtn.Text="+"
    else tw(MainFrame,{Size=UDim2.new(0,s.w,0,s.h)},0.25,Enum.EasingStyle.Back); MinBtn.Text="–" end
end)

-- ============================================================
-- MENU BUTTON (draggable, bottom-left)
-- ============================================================
local MenuBtn=Instance.new("TextButton",ScreenGui)
MenuBtn.Text="☰ InfHub"; MenuBtn.Size=UDim2.new(0,100,0,34)
MenuBtn.Position=UDim2.new(0,14,1,-115)
MenuBtn.BackgroundColor3=Color3.fromRGB(12,12,20); MenuBtn.TextColor3=Color3.fromRGB(185,200,255)
MenuBtn.Font=Enum.Font.GothamBold; MenuBtn.TextSize=13; MenuBtn.BorderSizePixel=0; MenuBtn.ZIndex=20; MenuBtn.Active=true
Instance.new("UICorner",MenuBtn).CornerRadius=UDim.new(0,8)
local mbAcc=Instance.new("Frame",MenuBtn)
mbAcc.Size=UDim2.new(0,3,0.7,0); mbAcc.Position=UDim2.new(0,0,0.15,0)
mbAcc.BackgroundColor3=Color3.fromRGB(55,145,255); mbAcc.BorderSizePixel=0; mbAcc.ZIndex=21
Instance.new("UICorner",mbAcc).CornerRadius=UDim.new(1,0)
-- pulse
task.spawn(function()
    while true do
        tw(mbAcc,{BackgroundColor3=Color3.fromRGB(95,195,255)},1,Enum.EasingStyle.Sine); task.wait(1)
        tw(mbAcc,{BackgroundColor3=Color3.fromRGB(35,90,195)},1,Enum.EasingStyle.Sine); task.wait(1)
    end
end)

local mbDrag=false; local mbStart,mbStartPos; local mbMoved=false
MenuBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        mbDrag=true; mbStart=i.Position; mbStartPos=MenuBtn.Position; mbMoved=false
    end
end)
MenuBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mbDrag=false end
end)
UIS.InputChanged:Connect(function(i)
    if mbDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-mbStart
        if d.Magnitude>6 then
            mbMoved=true
            MenuBtn.Position=UDim2.new(mbStartPos.X.Scale,mbStartPos.X.Offset+d.X,mbStartPos.Y.Scale,mbStartPos.Y.Offset+d.Y)
        end
    end
end)
MenuBtn.MouseButton1Click:Connect(function()
    if mbMoved then return end
    playClick()
    local s=sz()
    if not MainFrame.Visible then
        MainFrame.Size=UDim2.new(0,s.w,0,0); MainFrame.Visible=true
        tw(MainFrame,{Size=UDim2.new(0,s.w,0,s.h)},0.3,Enum.EasingStyle.Back)
    else
        tw(MainFrame,{Size=UDim2.new(0,s.w,0,0)},0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        task.wait(0.2); MainFrame.Visible=false; MainFrame.Size=UDim2.new(0,s.w,0,s.h)
    end
end)

-- RightShift toggle
UIS.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode==Enum.KeyCode.RightShift then MenuBtn.MouseButton1Click:Fire() end
end)

-- ============================================================
-- 📱 MOBILE FLY BUTTONS
-- ============================================================
if isMobile then
    local sg=Instance.new("ScreenGui",player.PlayerGui)
    sg.Name="InfHub_FlyMobile"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
    local function mkBtn(t2,pos,dn,up)
        local b=Instance.new("TextButton",sg)
        b.Text=t2; b.Size=UDim2.new(0,60,0,60); b.Position=pos
        b.BackgroundColor3=Color3.fromRGB(12,12,20); b.BackgroundTransparency=0.28
        b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=20; b.BorderSizePixel=0
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
        b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then dn() end end)
        b.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then up() end end)
    end
    mkBtn("⬆",UDim2.new(0,74,1,-215),function() mFwd=true end,function() mFwd=false end)
    mkBtn("⬇",UDim2.new(0,74,1,-143),function() mBwd=true end,function() mBwd=false end)
    mkBtn("⬅",UDim2.new(0,5, 1,-179),function() mLeft=true end,function() mLeft=false end)
    mkBtn("➡",UDim2.new(0,144,1,-179),function() mRight=true end,function() mRight=false end)
    mkBtn("🔼",UDim2.new(1,-74,1,-215),function() mUp=true end,function() mUp=false end)
    mkBtn("🔽",UDim2.new(1,-74,1,-143),function() mDown=true end,function() mDown=false end)
    RunService.RenderStepped:Connect(function() sg.Enabled=flying end)
end

-- ============================================================
-- CORE ENGINE
-- ============================================================

-- Fly
task.spawn(function()
    while true do
        task.wait()
        local root=getRoot(); local hum=getHum()
        if flying and root and hum then
            local bg=root:FindFirstChild("FlyGyro") or Instance.new("BodyGyro",root)
            bg.Name="FlyGyro"; bg.P=9e4; bg.maxTorque=Vector3.new(9e9,9e9,9e9)
            local bv=root:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity",root)
            bv.Name="FlyVelocity"; bv.maxForce=Vector3.new(9e9,9e9,9e9)
            hum.PlatformStand=true
            ctrl.f=(UIS:IsKeyDown(Enum.KeyCode.W) or mFwd) and 1 or 0
            ctrl.b=(UIS:IsKeyDown(Enum.KeyCode.S) or mBwd) and -1 or 0
            ctrl.l=(UIS:IsKeyDown(Enum.KeyCode.A) or mLeft) and -1 or 0
            ctrl.r=(UIS:IsKeyDown(Enum.KeyCode.D) or mRight) and 1 or 0
            local alt=0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or mUp then alt=flySpeed end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or mDown then alt=-flySpeed end
            local moving=ctrl.l+ctrl.r~=0 or ctrl.f+ctrl.b~=0 or alt~=0
            flySpeedVal=moving and math.min(flySpeedVal+0.5+flySpeedVal/flySpeed,flySpeed) or math.max(flySpeedVal-1,0)
            local fwd2=camera.CFrame.lookVector*(ctrl.f+ctrl.b)
            local side=(camera.CFrame*CFrame.new(ctrl.l+ctrl.r,0,0)).p-camera.CFrame.p
            local altV=Vector3.new(0,alt/math.max(flySpeed,1),0)
            local dir=fwd2+side+altV
            if moving and dir.Magnitude>0 then
                bv.velocity=dir.Unit*flySpeedVal; lastctrl={f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
            elseif flySpeedVal~=0 then
                local ld=camera.CFrame.lookVector*(lastctrl.f+lastctrl.b)+(camera.CFrame*CFrame.new(lastctrl.l+lastctrl.r,0,0)).p-camera.CFrame.p
                bv.velocity=ld.Magnitude>0 and ld.Unit*flySpeedVal or Vector3.new(0,0.1,0)
            else bv.velocity=Vector3.new(0,0.1,0) end
            bg.cframe=camera.CFrame*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*40*flySpeedVal/math.max(flySpeed,1)),0,0)
        else
            if root then
                if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
                if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
            end
            if hum then hum.PlatformStand=false end
        end
    end
end)

-- WalkSpeed / JumpPower / God Mode / FOV / Fullbright
RunService.RenderStepped:Connect(function()
    local hum=getHum()
    if hum and not flying then hum.WalkSpeed=walkSpeed; hum.JumpPower=jumpPower; hum.UseJumpPower=true end
    if godMode and hum then hum.Health=hum.MaxHealth end
    if fovChanger then camera.FieldOfView=fovValue end
    if fullbright then
        Lighting.Brightness=2; Lighting.ClockTime=14
        Lighting.GlobalShadows=false; Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
    end
    -- Aimbot
    if aimbot then
        local nearest,nearestDist=nil,math.huge
        local root=getRoot()
        if root then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=player and p.Character then
                    local r=p.Character:FindFirstChild("HumanoidRootPart")
                    if r then local d=(root.Position-r.Position).Magnitude; if d<nearestDist then nearestDist=d; nearest=r end end
                end
            end
            if nearest then camera.CFrame=CFrame.lookAt(camera.CFrame.Position,nearest.Position) end
        end
    end
end)

-- Noclip / Spin / Anti-fling / Bhop
RunService.Stepped:Connect(function()
    if player.Character then
        if noclip then
            for _,v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
        end
        if antifling then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=player and p.Character then
                    for _,part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide=false; part.Velocity=Vector3.new(0,0,0) end
                    end
                end
            end
        end
        if spinning and getRoot() then getRoot().CFrame=getRoot().CFrame*CFrame.Angles(0,math.rad(spinSpeed),0) end
    end
end)

-- Bhop
RunService.Heartbeat:Connect(function()
    if bhop then
        local hum=getHum(); local root=getRoot()
        if hum and root and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if infiniteJump and player.Character then
        local hum=getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti-AFK
task.spawn(function()
    while true do task.wait(55)
        if antiAFK then
            pcall(function() game:GetService("VirtualUser"):CaptureController(); game:GetService("VirtualUser"):ClickButton2(Vector2.new()) end)
            local hum=getHum(); if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- Auto Respawn
player.CharacterAdded:Connect(function(char)
    if autoRespawn then
        local hum=char:WaitForChild("Humanoid",5)
        if hum then hum.Died:Connect(function() if autoRespawn then task.wait(0.5); player:LoadCharacter() end end) end
    end
end)

-- Click TP
mouse.Button1Down:Connect(function()
    if (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or clickTP) and player.Character then
        player.Character:SetPrimaryPartCFrame(CFrame.new(mouse.Hit.p+Vector3.new(0,3,0)))
    end
end)

-- ESP loop
task.spawn(function()
    while task.wait(0.6) do
        for _,p in pairs(Players:GetPlayers()) do
            if p~=player and p.Character then
                local char=p.Character
                -- Highlight (chams/xray/playerESP)
                local hl=char:FindFirstChild("InfHL")
                if (playerESP or chams or xray) and not hl then
                    hl=Instance.new("Highlight",char); hl.Name="InfHL"
                elseif not(playerESP or chams or xray) and hl then hl:Destroy(); hl=nil end
                if hl then
                    hl.FillColor=chams and Color3.fromRGB(255,70,70) or Color3.fromRGB(0,110,255)
                    hl.FillTransparency=xray and 0.0 or 0.5
                    hl.DepthMode=xray and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
                end
                -- Name ESP
                local root=char:FindFirstChild("HumanoidRootPart")
                if root then
                    local bb=root:FindFirstChild("InfNameESP")
                    if nameESP and not bb then
                        bb=Instance.new("BillboardGui",root); bb.Name="InfNameESP"
                        bb.Size=UDim2.new(0,120,0,40); bb.AlwaysOnTop=true; bb.StudsOffset=Vector3.new(0,3,0)
                        local nl=Instance.new("TextLabel",bb)
                        nl.Name="NL"; nl.Size=UDim2.new(1,0,1,0); nl.BackgroundTransparency=1
                        nl.TextColor3=Color3.fromRGB(255,255,255); nl.Font=Enum.Font.GothamBold; nl.TextSize=12
                        nl.TextStrokeTransparency=0.5
                    elseif not nameESP and bb then bb:Destroy(); bb=nil end
                    if bb then
                        local nl=bb:FindFirstChild("NL")
                        if nl then
                            local dist=math.floor((root.Position-camera.CFrame.Position).Magnitude)
                            nl.Text=p.Name.."\n["..dist.."m]"
                        end
                    end
                    -- Box ESP
                    local sb=root:FindFirstChild("InfBox")
                    if boxESP and not sb then
                        sb=Instance.new("SelectionBox",root); sb.Name="InfBox"; sb.Adornee=char
                        sb.Color3=Color3.fromRGB(255,70,70); sb.SurfaceTransparency=1; sb.LineThickness=0.05
                    elseif not boxESP and sb then sb:Destroy() end
                    -- Tracers
                    local tr=root:FindFirstChild("InfTracer")
                    if tracers and not tr then
                        tr=Instance.new("SelectionBox",root); tr.Name="InfTracer"; tr.Adornee=root
                        tr.Color3=Color3.fromRGB(0,255,160); tr.SurfaceTransparency=1; tr.LineThickness=0.03
                    elseif not tracers and tr then tr:Destroy() end
                end
            end
        end
        -- Boss ESP
        for _,obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local h=obj:FindFirstChildOfClass("Humanoid")
                if h and h.MaxHealth>=5000 then
                    local ex=obj:FindFirstChild("InfBossESP")
                    if bossESP and not ex then
                        ex=Instance.new("Highlight",obj); ex.Name="InfBossESP"
                        ex.FillColor=Color3.fromRGB(255,50,0); ex.OutlineColor=Color3.fromRGB(255,200,0); ex.FillTransparency=0.35
                    elseif not bossESP and ex then ex:Destroy() end
                end
            end
        end
    end
end)

-- ============================================================
-- OPEN ANIMATION
-- ============================================================
local s0=sz()
MainFrame.Size=UDim2.new(0,s0.w,0,0); MainFrame.Position=UDim2.new(0.5,-s0.w/2,0.5,0)
task.wait(0.08)
tw(MainFrame,{Size=UDim2.new(0,s0.w,0,s0.h),Position=UDim2.new(0.5,-s0.w/2,0.5,-s0.h/2)},0.42,Enum.EasingStyle.Back)
task.wait(0.5)
notify("InfHub V2","Script loaded!",Color3.fromRGB(45,140,255))
task.wait(0.4)
notify("Tip",isMobile and "S/M/L to resize  •  drag ☰ button" or "RightShift to toggle  •  S/M/L to resize",Color3.fromRGB(70,70,110))
