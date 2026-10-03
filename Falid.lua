--// FALID GUI v26.0 (full, sounds, toasts, world customization) --//
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Config = {
    Aim = { Enabled=false, TargetPlayers=true, TargetBots=true, FOV=140, MaxDistance=2000,
        Smoothness=0.5, Bind=nil, WallCheck=false, AutoClick=true, AutoClickDist=80,
        ShowFOV=true, UseMouse=false },
    ESP = { Enabled=false, ShowPlayers=true, ShowBots=true, MaxDistance=1500, Bind=nil,
        Color=Color3.fromRGB(70,140,255),
        Presets = {
            { name="Красный", c=Color3.fromRGB(255,60,60) },
            { name="Оранжевый", c=Color3.fromRGB(255,150,40) },
            { name="Жёлтый", c=Color3.fromRGB(255,220,60) },
            { name="Зелёный", c=Color3.fromRGB(70,255,100) },
            { name="Голубой", c=Color3.fromRGB(70,220,255) },
            { name="Синий", c=Color3.fromRGB(70,140,255) },
            { name="Фиолетовый", c=Color3.fromRGB(180,80,255) },
            { name="Розовый", c=Color3.fromRGB(255,100,200) },
            { name="Белый", c=Color3.fromRGB(255,255,255) },
            { name="Чёрный", c=Color3.fromRGB(30,30,30) },
        } },
    Hitbox = { Enabled=false, Size=8, Transparency=0, Color=Color3.fromRGB(180,80,255),
        TargetPlayers=true, TargetBots=true, MaxDistance=2000, Bind=nil },
    Fly = { Enabled=false, Speed=60, Noclip=true, Bind=nil },
    ForceJump = { Enabled=false, Power=100, Bind=nil },
    Speed = { Enabled=false, Value=50, Bind=nil },
    Resize = { Enabled=false, Scale=0.4, AllPlayers=false, Bind=nil },
    Invis = { Enabled=false },
    Death = { Enabled=true, ShowText=true, ShowSound=true,
        SoundId="rbxassetid://5801257793", SoundVolume=3 },
    Sounds = {
        Enabled = true,
        MenuOpenId = "rbxasset://sounds/electronicpingshort.wav",
        MenuOpenVolume = 0.5,
        ToggleId = "rbxasset://sounds/switch.wav",
        ToggleVolume = 0.6,
        NotifyId = "rbxasset://sounds/electronicpingshort.wav",
        NotifyVolume = 0.5,
    },
    World = {
        TimeEnabled = false,
        ClockTime = 14,
        FogEnabled = false,
        FogColor = Color3.fromRGB(180,180,200),
        FogStart = 0,
        FogEnd = 1000,
        BrightnessEnabled = false,
        Brightness = 2,
        WeatherEnabled = false,
        WeatherType = "Rain", -- Rain, Snow, Leaves, Sparkles
        WeatherAmount = 60,
        WorldParticles = false,
        ParticleType = "Sparkles", -- Sparkles, Hearts, Stars
        ParticleAmount = 30,
    },
    GUI = { ToggleBind=Enum.KeyCode.RightShift, Transparency=0.08, Scale=1,
        Accent=Color3.fromRGB(120,80,255),
        AccentPresets = {
            { name="Фиолет", c=Color3.fromRGB(120,80,255) },
            { name="Синий", c=Color3.fromRGB(70,140,255) },
            { name="Голубой", c=Color3.fromRGB(70,220,255) },
            { name="Бирюза", c=Color3.fromRGB(60,240,200) },
            { name="Зелёный", c=Color3.fromRGB(70,220,120) },
            { name="Жёлтый", c=Color3.fromRGB(255,210,60) },
            { name="Оранж", c=Color3.fromRGB(255,140,40) },
            { name="Красный", c=Color3.fromRGB(255,60,60) },
            { name="Розовый", c=Color3.fromRGB(255,90,190) },
            { name="Белый", c=Color3.fromRGB(240,240,250) },
        } },
    Discord = "https://discord.gg/5WnZJjTMfa",
    InvisScriptURL = "https://pastebin.com/raw/3Rnd9rHf"
}

local function getGuiParent()
    if gethui then
        local ok, hidden = pcall(gethui)
        if ok and hidden then return hidden end
    end
    if CoreGui then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local gui = Instance.new("ScreenGui")
gui.Name="Falid"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.DisplayOrder=999
gui.Parent = getGuiParent()

----------------------------------------------------------------
-- UI SOUNDS
----------------------------------------------------------------
local function playUISound(soundId, volume)
    if not Config.Sounds.Enabled then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = soundId or Config.Sounds.ToggleId
        s.Volume = volume or Config.Sounds.ToggleVolume
        s.Parent = SoundService
        s:Play()
        Debris:AddItem(s, 4)
    end)
end
local function playMenuOpen() playUISound(Config.Sounds.MenuOpenId, Config.Sounds.MenuOpenVolume) end
local function playToggle() playUISound(Config.Sounds.ToggleId, Config.Sounds.ToggleVolume) end
local function playNotify() playUISound(Config.Sounds.NotifyId, Config.Sounds.NotifyVolume) end

----------------------------------------------------------------
-- BIND HELPERS
----------------------------------------------------------------
local function bindDisplayName(bind)
    if not bind then return "None" end
    local n = bind.Name
    if n=="MouseButton1" then return "ЛКМ"
    elseif n=="MouseButton2" then return "ПКМ"
    elseif n=="MouseButton3" then return "СКМ"
    elseif n=="MouseButton4" then return "МБ4"
    elseif n=="MouseButton5" then return "МБ5" end
    return n
end
local function isMouseBind(input)
    local n = input.UserInputType.Name
    return n=="MouseButton1" or n=="MouseButton2" or n=="MouseButton3"
        or n=="MouseButton4" or n=="MouseButton5"
end

----------------------------------------------------------------
-- TOAST
----------------------------------------------------------------
local toastContainer = Instance.new("Frame")
toastContainer.Size=UDim2.fromScale(1,1)
toastContainer.BackgroundTransparency=1
toastContainer.ZIndex=500
toastContainer.Parent=gui

local function showToast(text, color)
    color = color or Config.GUI.Accent
    playNotify()
    local toast = Instance.new("TextButton")
    toast.Size=UDim2.fromOffset(280,44)
    toast.AnchorPoint=Vector2.new(0.5,0)
    toast.Position=UDim2.new(0.5,0,0,-60)
    toast.BackgroundColor3=Color3.fromRGB(24,24,32)
    toast.Text=""; toast.AutoButtonColor=false
    toast.ZIndex=501; toast.Parent=toastContainer
    Instance.new("UICorner", toast).CornerRadius=UDim.new(0,10)
    local stroke = Instance.new("UIStroke")
    stroke.Color=color; stroke.Thickness=1.5; stroke.Transparency=0.2; stroke.Parent=toast
    local icon = Instance.new("Frame")
    icon.Size=UDim2.fromOffset(24,24); icon.Position=UDim2.new(0,10,0.5,-12)
    icon.BackgroundColor3=color; icon.BorderSizePixel=0; icon.ZIndex=502; icon.Parent=toast
    Instance.new("UICorner", icon).CornerRadius=UDim.new(1,0)
    local check = Instance.new("TextLabel")
    check.Size=UDim2.fromScale(1,1); check.BackgroundTransparency=1
    check.Text="✓"; check.Font=Enum.Font.GothamBold
    check.TextSize=16; check.TextColor3=Color3.fromRGB(255,255,255)
    check.ZIndex=503; check.Parent=icon
    local label = Instance.new("TextLabel")
    label.Size=UDim2.new(1,-48,1,0); label.Position=UDim2.new(0,42,0,0)
    label.BackgroundTransparency=1; label.Text=text
    label.Font=Enum.Font.GothamSemibold; label.TextSize=13
    label.TextColor3=Color3.fromRGB(240,240,250)
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.ZIndex=502; label.Parent=toast
    TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position=UDim2.new(0.5,0,0,24) }):Play()
    task.delay(2.2, function()
        local tw = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position=UDim2.new(0.5,0,0,-60), BackgroundTransparency=1 })
        tw:Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency=1 }):Play()
        TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency=1 }):Play()
        TweenService:Create(check, TweenInfo.new(0.3), { TextTransparency=1 }):Play()
        TweenService:Create(icon, TweenInfo.new(0.3), { BackgroundTransparency=1 }):Play()
        tw.Completed:Connect(function() toast:Destroy() end)
    end)
end

----------------------------------------------------------------
-- DEATH EFFECT
----------------------------------------------------------------
local deathGui = Instance.new("ScreenGui")
deathGui.Name="Falid_Death"; deathGui.ResetOnSpawn=false
deathGui.IgnoreGuiInset=true; deathGui.DisplayOrder=997
deathGui.Parent=getGuiParent()

local deathOverlay = Instance.new("Frame")
deathOverlay.Size=UDim2.fromScale(1,1)
deathOverlay.BackgroundColor3=Color3.fromRGB(200,0,0)
deathOverlay.BackgroundTransparency=1; deathOverlay.BorderSizePixel=0
deathOverlay.Visible=false; deathOverlay.ZIndex=900
deathOverlay.Parent=deathGui

local deathVignette = Instance.new("Frame")
deathVignette.Size=UDim2.fromScale(1,1)
deathVignette.BackgroundColor3=Color3.fromRGB(0,0,0)
deathVignette.BackgroundTransparency=1; deathVignette.BorderSizePixel=0
deathVignette.Visible=false; deathVignette.ZIndex=901
deathVignette.Parent=deathGui

local deathText = Instance.new("TextLabel")
deathText.Size=UDim2.fromScale(1,1); deathText.BackgroundTransparency=1
deathText.Text="ТЫ УМЕР"; deathText.Font=Enum.Font.GothamBlack
deathText.TextSize=110; deathText.TextColor3=Color3.fromRGB(255,255,255)
deathText.TextTransparency=1; deathText.TextStrokeTransparency=1
deathText.TextStrokeColor3=Color3.fromRGB(200,0,0); deathText.ZIndex=902
deathText.Parent=deathGui

local deathSub = Instance.new("TextLabel")
deathSub.Size=UDim2.new(1,0,0,40); deathSub.Position=UDim2.new(0.5,0,0.5,90)
deathSub.AnchorPoint=Vector2.new(0.5,0); deathSub.BackgroundTransparency=1
deathSub.Text="FALID"; deathSub.Font=Enum.Font.GothamBold
deathSub.TextSize=22; deathSub.TextColor3=Config.GUI.Accent
deathSub.TextTransparency=1; deathSub.ZIndex=902; deathSub.Parent=deathGui

local function playDeathSound()
    if not Config.Death.ShowSound then return end
    local id=Config.Death.SoundId; local vol=Config.Death.SoundVolume
    pcall(function()
        local s=Instance.new("Sound"); s.SoundId=id; s.Volume=vol
        s.PlayOnRemove=true; s.Parent=workspace; s:Destroy()
    end)
    pcall(function()
        local s=Instance.new("Sound"); s.SoundId=id; s.Volume=vol
        s.Parent=SoundService; s:Play(); Debris:AddItem(s,8)
    end)
    pcall(function()
        local char=LocalPlayer.Character
        local root=char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char:FindFirstChild("Torso"))
        if root then
            local s=Instance.new("Sound"); s.SoundId=id; s.Volume=vol
            s.Parent=root; s:Play(); Debris:AddItem(s,8)
        end
    end)
end

local deathActive=false
local function triggerDeathEffect()
    if deathActive then return end
    if not Config.Death.Enabled then return end
    deathActive=true
    playDeathSound()
    if Config.Death.ShowText then
        deathOverlay.Visible=true; deathVignette.Visible=true
        TweenService:Create(deathOverlay, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency=0.55 }):Play()
        TweenService:Create(deathVignette, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency=0.2 }):Play()
        deathText.TextTransparency=1; deathText.TextStrokeTransparency=1
        deathText.TextSize=60; deathSub.TextTransparency=1
        TweenService:Create(deathText, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { TextTransparency=0, TextStrokeTransparency=0.3, TextSize=120 }):Play()
        TweenService:Create(deathSub, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { TextTransparency=0.2 }):Play()
        task.spawn(function()
            for _=1,3 do
                TweenService:Create(deathOverlay, TweenInfo.new(0.12), { BackgroundTransparency=0.15 }):Play()
                task.wait(0.12)
                TweenService:Create(deathOverlay, TweenInfo.new(0.18), { BackgroundTransparency=0.55 }):Play()
                task.wait(0.18)
            end
        end)
        task.delay(2.0, function()
            TweenService:Create(deathOverlay, TweenInfo.new(0.5), { BackgroundTransparency=1 }):Play()
            TweenService:Create(deathVignette, TweenInfo.new(0.5), { BackgroundTransparency=1 }):Play()
            TweenService:Create(deathText, TweenInfo.new(0.5), { TextTransparency=1, TextStrokeTransparency=1 }):Play()
            TweenService:Create(deathSub, TweenInfo.new(0.5), { TextTransparency=1 }):Play()
            task.wait(0.6)
            deathOverlay.Visible=false; deathVignette.Visible=false; deathActive=false
        end)
    else
        deathActive=false
    end
end
local function hookCharacterDeath(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    hum.Died:Connect(function() task.wait(0.15); triggerDeathEffect() end)
end
if LocalPlayer.Character then hookCharacterDeath(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char) hookCharacterDeath(char) end)

----------------------------------------------------------------
-- FOV
----------------------------------------------------------------
local fovGui = Instance.new("ScreenGui")
fovGui.Name="Falid_FOV"; fovGui.ResetOnSpawn=false
fovGui.IgnoreGuiInset=true; fovGui.DisplayOrder=998
fovGui.Parent=getGuiParent()
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint=Vector2.new(0.5,0.5)
fovCircle.Position=UDim2.fromScale(0.5,0.5)
fovCircle.BackgroundTransparency=1; fovCircle.Visible=false
fovCircle.Parent=fovGui
Instance.new("UICorner", fovCircle).CornerRadius=UDim.new(1,0)
local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness=1.5; fovStroke.Color=Config.GUI.Accent
fovStroke.Transparency=0.25; fovStroke.Parent=fovCircle
local function updateFovCircle()
    fovCircle.Size=UDim2.fromOffset(Config.Aim.FOV*2, Config.Aim.FOV*2)
    fovCircle.Visible=Config.Aim.Enabled and Config.Aim.ShowFOV
end
local function isMenuOpen() return GuiService:IsMenuOpen() end

----------------------------------------------------------------
-- LOADER
----------------------------------------------------------------
local darkOverlay = Instance.new("Frame")
darkOverlay.Size=UDim2.fromScale(1,1); darkOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
darkOverlay.BackgroundTransparency=1; darkOverlay.BorderSizePixel=0
darkOverlay.ZIndex=200; darkOverlay.Parent=gui

local shardsContainer = Instance.new("Frame")
shardsContainer.Size=UDim2.fromScale(1,1); shardsContainer.BackgroundTransparency=1
shardsContainer.ZIndex=201; shardsContainer.Parent=gui

local logoText = Instance.new("TextLabel")
logoText.BackgroundTransparency=1; logoText.Text="F A L I D"
logoText.Font=Enum.Font.GothamBlack; logoText.TextSize=78
logoText.TextColor3=Color3.fromRGB(245,245,255); logoText.TextTransparency=1
logoText.Size=UDim2.fromOffset(600,120); logoText.AnchorPoint=Vector2.new(0.5,0.5)
logoText.Position=UDim2.fromScale(0.5,0.5); logoText.ZIndex=203; logoText.Parent=gui

local logoGlow = Instance.new("TextLabel")
logoGlow.BackgroundTransparency=1; logoGlow.Text="F A L I D"
logoGlow.Font=Enum.Font.GothamBlack; logoGlow.TextSize=78
logoGlow.TextColor3=Config.GUI.Accent; logoGlow.TextTransparency=1
logoGlow.Size=UDim2.fromOffset(600,120); logoGlow.AnchorPoint=Vector2.new(0.5,0.5)
logoGlow.Position=UDim2.fromScale(0.5,0.5); logoGlow.ZIndex=202; logoGlow.Parent=gui

local shardList = {}
local SHARD_COUNT=700; local SHARD_TO_TEXT=350
local TEXT_HALF_W=240; local TEXT_HALF_H=55
for i=1,SHARD_COUNT do
    local isText = i <= SHARD_TO_TEXT
    local s = math.random(3,7)
    local shard = Instance.new("Frame")
    shard.Size=UDim2.fromOffset(s,s); shard.AnchorPoint=Vector2.new(0.5,0.5)
    shard.BackgroundColor3=Config.GUI.Accent; shard.BorderSizePixel=0
    shard.Rotation=math.random(0,360); shard.ZIndex=201; shard.BackgroundTransparency=1
    local sx,sy
    if isText then
        local edge=math.random(1,4)
        if edge==1 then sx=math.random(-15,115)/100; sy=-0.15
        elseif edge==2 then sx=1.15; sy=math.random(-15,115)/100
        elseif edge==3 then sx=math.random(-15,115)/100; sy=1.15
        else sx=-0.15; sy=math.random(-15,115)/100 end
    else
        sx=math.random(-5,105)/100; sy=math.random(-5,105)/100
    end
    shard.Position=UDim2.fromScale(sx,sy)
    if s>=6 then Instance.new("UICorner", shard).CornerRadius=UDim.new(1,0)
    else Instance.new("UICorner", shard).CornerRadius=UDim.new(0,1) end
    shard.Parent=shardsContainer
    if isText then
        shardList[i]={ frame=shard, isText=true,
            targetOffset=Vector2.new(math.random(-TEXT_HALF_W,TEXT_HALF_W), math.random(-TEXT_HALF_H,TEXT_HALF_H)),
            delay=math.random(0,5)/100, driftOffset=Vector2.new(0,0) }
    else
        shardList[i]={ frame=shard, isText=false,
            delay=math.random(0,10)/100,
            driftOffset=Vector2.new((math.random()-0.5)*0.15, (math.random()-0.5)*0.15) }
    end
end

----------------------------------------------------------------
-- MAIN
----------------------------------------------------------------
local main = Instance.new("Frame")
main.Size=UDim2.fromOffset(700,460)
main.AnchorPoint=Vector2.new(0.5,0.5); main.Position=UDim2.fromScale(0.5,0.5)
main.BackgroundColor3=Color3.fromRGB(16,16,22)
main.BackgroundTransparency=1; main.BorderSizePixel=0
main.Visible=false; main.Parent=gui
Instance.new("UICorner", main).CornerRadius=UDim.new(0,14)
local mainScale = Instance.new("UIScale")
mainScale.Scale=Config.GUI.Scale; mainScale.Parent=main
local mStroke = Instance.new("UIStroke"); mStroke.Color=Config.GUI.Accent
mStroke.Thickness=1.5; mStroke.Transparency=1; mStroke.Parent=main

local settingsPanel
local function isOver(guiObj, x, y)
    if not guiObj or not guiObj.Visible then return false end
    local p=guiObj.AbsolutePosition; local s=guiObj.AbsoluteSize
    return x>=p.X and x<=p.X+s.X and y>=p.Y and y<=p.Y+s.Y
end
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        local x,y=input.Position.X, input.Position.Y
        if isOver(settingsPanel, x, y) then return end
        dragging=true; dragStart=input.Position; startPos=main.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local d=input.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

local title = Instance.new("TextLabel")
title.BackgroundTransparency=1; title.Size=UDim2.new(1,-30,0,40)
title.Position=UDim2.fromOffset(20,8); title.Font=Enum.Font.GothamBold
title.Text="FALID"; title.TextSize=24
title.TextColor3=Color3.fromRGB(245,245,255)
title.TextXAlignment=Enum.TextXAlignment.Left; title.Parent=main

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency=1; subtitle.Size=UDim2.new(1,-30,0,16)
subtitle.Position=UDim2.fromOffset(22,42); subtitle.Font=Enum.Font.Gotham
subtitle.Text="Main / Teleport / World"; subtitle.TextSize=11
subtitle.TextColor3=Color3.fromRGB(145,145,160)
subtitle.TextXAlignment=Enum.TextXAlignment.Left; subtitle.Parent=main

-- Discord icon
local menuDiscordBtn = Instance.new("TextButton")
menuDiscordBtn.Size=UDim2.fromOffset(36,36)
menuDiscordBtn.Position=UDim2.new(1,-95,0,14)
menuDiscordBtn.BackgroundColor3=Color3.fromRGB(30,30,40)
menuDiscordBtn.Text=""; menuDiscordBtn.AutoButtonColor=false
menuDiscordBtn.Parent=main
Instance.new("UICorner", menuDiscordBtn).CornerRadius=UDim.new(0,8)
local mIcon = Instance.new("Frame")
mIcon.Size=UDim2.fromOffset(20,14)
mIcon.AnchorPoint=Vector2.new(0.5,0.5); mIcon.Position=UDim2.fromScale(0.5,0.5)
mIcon.BackgroundColor3=Color3.fromRGB(120,80,255)
mIcon.BorderSizePixel=0; mIcon.Parent=menuDiscordBtn
Instance.new("UICorner", mIcon).CornerRadius=UDim.new(0,4)
local function makeMenuEye(offX)
    local e=Instance.new("Frame")
    e.Size=UDim2.fromOffset(3,3)
    e.Position=UDim2.new(0.5,offX,0.5,-2)
    e.BackgroundColor3=Color3.fromRGB(255,255,255)
    e.BorderSizePixel=0; e.Parent=mIcon
    Instance.new("UICorner", e).CornerRadius=UDim.new(1,0)
end
makeMenuEye(-6); makeMenuEye(3)
menuDiscordBtn.MouseButton1Click:Connect(function()
    local copied = pcall(function() setclipboard(Config.Discord) end)
    if copied then showToast("Discord скопирован!", Color3.fromRGB(120,80,255))
    else showToast("Ошибка копирования", Color3.fromRGB(255,60,60)) end
end)

local globalGearBtn = Instance.new("TextButton")
globalGearBtn.Size=UDim2.fromOffset(36,36)
globalGearBtn.Position=UDim2.new(1,-50,0,14)
globalGearBtn.BackgroundColor3=Color3.fromRGB(30,30,40)
globalGearBtn.Text="⚙"; globalGearBtn.Font=Enum.Font.GothamBold
globalGearBtn.TextSize=20; globalGearBtn.TextColor3=Color3.fromRGB(200,200,215)
globalGearBtn.AutoButtonColor=false; globalGearBtn.Parent=main
Instance.new("UICorner", globalGearBtn).CornerRadius=UDim.new(0,8)

local tabBar = Instance.new("Frame")
tabBar.BackgroundTransparency=1; tabBar.Position=UDim2.fromOffset(20,68)
tabBar.Size=UDim2.new(1,-40,0,32); tabBar.Parent=main
local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.Padding=UDim.new(0,6); tabLayout.Parent=tabBar

local container = Instance.new("ScrollingFrame")
container.BackgroundTransparency=1; container.BorderSizePixel=0
container.Position=UDim2.fromOffset(20,108)
container.Size=UDim2.new(1,-40,1,-128)
container.CanvasSize=UDim2.new(0,0,0,0); container.ScrollBarThickness=6
container.ScrollBarImageColor3=Config.GUI.Accent
container.ScrollingDirection=Enum.ScrollingDirection.Y
container.ElasticBehavior=Enum.ElasticBehavior.Never; container.Parent=main
pcall(function() container.AutomaticCanvasSize=Enum.AutomaticSize.Y end)

local tabs = {}
local function switchTab(name)
    for tName, tab in pairs(tabs) do
        local isActive=(tName==name)
        tab.content.Visible=isActive
        tab.button.BackgroundColor3=isActive and Config.GUI.Accent or Color3.fromRGB(30,30,40)
        tab.button.TextColor3=isActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,215)
    end
end
local function createTab(name, display, width, skipLayout)
    local btn = Instance.new("TextButton")
    btn.Size=UDim2.fromOffset(width or 100,32)
    btn.BackgroundColor3=Color3.fromRGB(30,30,40)
    btn.Text=display; btn.Font=Enum.Font.GothamSemibold
    btn.TextSize=13; btn.TextColor3=Color3.fromRGB(200,200,215)
    btn.AutoButtonColor=false; btn.Parent=tabBar
    Instance.new("UICorner", btn).CornerRadius=UDim.new(0,8)
    local content = Instance.new("Frame")
    content.BackgroundTransparency=1; content.Size=UDim2.new(1,0,0,0)
    content.AutomaticSize=Enum.AutomaticSize.Y
    content.Visible=false; content.Parent=container
    if not skipLayout then
        local layout = Instance.new("UIListLayout")
        layout.Padding=UDim.new(0,10); layout.SortOrder=Enum.SortOrder.LayoutOrder
        layout.Parent=content
    end
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabs[name]={ button=btn, content=content }
    return content
end
local mainTab = createTab("main", "Main", 90)
local tpTab = createTab("tp", "Teleport", 100, true)
tpTab.Size=UDim2.new(1,0,1,0); tpTab.AutomaticSize=Enum.AutomaticSize.None
local worldTab = createTab("world", "World", 90)
local miscTab = createTab("misc", "Misc", 80)

local function createRow(parent, name, description)
    local row = Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,62)
    row.BackgroundColor3=Color3.fromRGB(25,25,33)
    row.BorderSizePixel=0; row.Parent=parent
    Instance.new("UICorner", row).CornerRadius=UDim.new(0,10)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency=1; label.Position=UDim2.fromOffset(15,7)
    label.Size=UDim2.new(1,-130,0,23)
    label.Font=Enum.Font.GothamSemibold; label.Text=name
    label.TextSize=15; label.TextColor3=Color3.fromRGB(235,235,245)
    label.TextXAlignment=Enum.TextXAlignment.Left; label.Parent=row
    local desc = Instance.new("TextLabel")
    desc.BackgroundTransparency=1; desc.Position=UDim2.fromOffset(15,30)
    desc.Size=UDim2.new(1,-130,0,20)
    desc.Font=Enum.Font.Gotham; desc.Text=description
    desc.TextSize=11; desc.TextColor3=Color3.fromRGB(135,135,150)
    desc.TextXAlignment=Enum.TextXAlignment.Left; desc.Parent=row
    return row
end
local function createToggle(row, default, callback)
    local button = Instance.new("TextButton")
    button.Size=UDim2.fromOffset(65,30)
    button.Position=UDim2.new(1,-105,0.5,-15)
    button.BackgroundColor3=Color3.fromRGB(45,45,55)
    button.Text=""; button.AutoButtonColor=false; button.Parent=row
    Instance.new("UICorner", button).CornerRadius=UDim.new(1,0)
    local state=default
    local function update()
        button.BackgroundColor3 = state and Config.GUI.Accent or Color3.fromRGB(45,45,55)
        callback(state)
    end
    button.MouseButton1Click:Connect(function()
        state = not state
        playToggle()
        update()
    end)
    update()
    return button, function(v) state=v; update() end
end
local function createGear(row, callback)
    local gear = Instance.new("TextButton")
    gear.Size=UDim2.fromOffset(32,32)
    gear.Position=UDim2.new(1,-40,0.5,-16)
    gear.BackgroundTransparency=1; gear.Text="⚙"
    gear.Font=Enum.Font.GothamBold; gear.TextSize=20
    gear.TextColor3=Color3.fromRGB(170,170,185); gear.Parent=row
    gear.MouseButton1Click:Connect(callback)
    return gear
end

----------------------------------------------------------------
-- SETTINGS PANEL
----------------------------------------------------------------
settingsPanel = Instance.new("Frame")
settingsPanel.Size=UDim2.fromOffset(260,420)
settingsPanel.Position=UDim2.new(1,10,0,20)
settingsPanel.BackgroundColor3=Color3.fromRGB(20,20,28)
settingsPanel.BorderSizePixel=0; settingsPanel.Visible=false
settingsPanel.Parent=main
Instance.new("UICorner", settingsPanel).CornerRadius=UDim.new(0,12)
local sps = Instance.new("UIStroke"); sps.Color=Config.GUI.Accent
sps.Transparency=0.3; sps.Parent=settingsPanel

local spTitle = Instance.new("TextLabel")
spTitle.BackgroundTransparency=1; spTitle.Size=UDim2.new(1,-20,0,40)
spTitle.Position=UDim2.fromOffset(10,5); spTitle.Font=Enum.Font.GothamBold
spTitle.Text="Настройки"; spTitle.TextSize=18
spTitle.TextColor3=Color3.fromRGB(240,240,250)
spTitle.TextXAlignment=Enum.TextXAlignment.Left; spTitle.Parent=settingsPanel

local spContent = Instance.new("ScrollingFrame")
spContent.BackgroundTransparency=1; spContent.BorderSizePixel=0
spContent.Position=UDim2.fromOffset(10,50)
spContent.Size=UDim2.new(1,-20,1,-60)
spContent.CanvasSize=UDim2.new(0,0,0,0)
spContent.ScrollBarThickness=6
spContent.ScrollBarImageColor3=Config.GUI.Accent
spContent.ScrollingDirection=Enum.ScrollingDirection.Y
spContent.Active=true; spContent.ElasticBehavior=Enum.ElasticBehavior.Never
spContent.Parent=settingsPanel
pcall(function() spContent.AutomaticCanvasSize=Enum.AutomaticSize.Y end)
local spLayout = Instance.new("UIListLayout")
spLayout.Padding=UDim.new(0,8); spLayout.Parent=spContent

local currentPanel=nil
local function clearSettings()
    for _,v in ipairs(spContent:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
    spContent.CanvasPosition=Vector2.new(0,0)
end
local function settingLabel(text)
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,28)
    l.Font=Enum.Font.GothamSemibold; l.Text=text
    l.TextSize=12; l.TextColor3=Color3.fromRGB(200,200,215)
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=spContent
end
local function settingButton(text, callback)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,34)
    b.BackgroundColor3=Color3.fromRGB(34,34,44)
    b.Text=text; b.Font=Enum.Font.Gotham
    b.TextSize=12; b.TextColor3=Color3.fromRGB(220,220,230)
    b.Parent=spContent
    Instance.new("UICorner", b).CornerRadius=UDim.new(0,7)
    b.MouseButton1Click:Connect(function() playToggle(); callback() end)
    return b
end
local function settingSwatch(label, getColorFn, onPrev, onNext)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,34)
    row.BackgroundColor3=Color3.fromRGB(34,34,44)
    row.BorderSizePixel=0; row.Parent=spContent
    Instance.new("UICorner", row).CornerRadius=UDim.new(0,7)
    local name=Instance.new("TextLabel")
    name.BackgroundTransparency=1; name.Position=UDim2.fromOffset(10,0)
    name.Size=UDim2.new(1,-100,1,0); name.Font=Enum.Font.Gotham
    name.Text=label; name.TextSize=12
    name.TextColor3=Color3.fromRGB(220,220,230)
    name.TextXAlignment=Enum.TextXAlignment.Left; name.Parent=row
    local swatch=Instance.new("Frame")
    swatch.Size=UDim2.fromOffset(28,22)
    swatch.Position=UDim2.new(1,-100,0.5,-11)
    swatch.BackgroundColor3=getColorFn(); swatch.BorderSizePixel=0; swatch.Parent=row
    Instance.new("UICorner", swatch).CornerRadius=UDim.new(0,5)
    local prev=Instance.new("TextButton")
    prev.Size=UDim2.fromOffset(22,22)
    prev.Position=UDim2.new(1,-70,0.5,-11)
    prev.BackgroundColor3=Color3.fromRGB(48,48,60)
    prev.Text="◀"; prev.Font=Enum.Font.GothamBold
    prev.TextSize=12; prev.TextColor3=Color3.fromRGB(220,220,230)
    prev.Parent=row
    Instance.new("UICorner", prev).CornerRadius=UDim.new(0,5)
    local nextB=Instance.new("TextButton")
    nextB.Size=UDim2.fromOffset(22,22)
    nextB.Position=UDim2.new(1,-44,0.5,-11)
    nextB.BackgroundColor3=Color3.fromRGB(48,48,60)
    nextB.Text="▶"; nextB.Font=Enum.Font.GothamBold
    nextB.TextSize=12; nextB.TextColor3=Color3.fromRGB(220,220,230)
    nextB.Parent=row
    Instance.new("UICorner", nextB).CornerRadius=UDim.new(0,5)
    prev.MouseButton1Click:Connect(function() playToggle(); onPrev(); swatch.BackgroundColor3=getColorFn() end)
    nextB.MouseButton1Click:Connect(function() playToggle(); onNext(); swatch.BackgroundColor3=getColorFn() end)
end
local function settingSlider(minV, maxV, initV, onChange)
    local holder=Instance.new("Frame")
    holder.Size=UDim2.new(1,0,0,42)
    holder.BackgroundColor3=Color3.fromRGB(34,34,44)
    holder.BorderSizePixel=0; holder.Parent=spContent
    Instance.new("UICorner", holder).CornerRadius=UDim.new(0,7)
    local valLabel=Instance.new("TextLabel")
    valLabel.BackgroundTransparency=1; valLabel.Size=UDim2.new(1,-20,0,16)
    valLabel.Position=UDim2.fromOffset(10,3); valLabel.Font=Enum.Font.Gotham
    valLabel.Text=tostring(math.floor(initV*100)/100); valLabel.TextSize=11
    valLabel.TextColor3=Color3.fromRGB(200,200,215)
    valLabel.TextXAlignment=Enum.TextXAlignment.Right; valLabel.Parent=holder
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(1,-20,0,8); bar.Position=UDim2.new(0,10,1,-16)
    bar.BackgroundColor3=Color3.fromRGB(55,55,70); bar.BorderSizePixel=0; bar.Parent=holder
    Instance.new("UICorner", bar).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((initV-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3=Config.GUI.Accent; fill.BorderSizePixel=0; fill.Parent=bar
    Instance.new("UICorner", fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.fromOffset(14,14); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((initV-minV)/(maxV-minV),0,0.5,0)
    knob.BackgroundColor3=Color3.fromRGB(240,240,250); knob.BorderSizePixel=0; knob.Parent=bar
    Instance.new("UICorner", knob).CornerRadius=UDim.new(1,0)
    local dr=false
    local function setFromX(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local v=math.floor((minV+rel*(maxV-minV))*100)/100
        fill.Size=UDim2.new(rel,0,1,0); knob.Position=UDim2.new(rel,0,0.5,0)
        valLabel.Text=tostring(v); onChange(v)
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dr=true; setFromX(input.Position.X) end end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dr=true end end)
    UserInputService.InputChanged:Connect(function(input)
        if dr and input.UserInputType==Enum.UserInputType.MouseMovement then setFromX(input.Position.X) end end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end end)
    return holder
end

local function findPresetIndex(color, presets)
    local best, bestD=1, math.huge
    for i,p in ipairs(presets) do
        local d=(p.c.R-color.R)^2+(p.c.G-color.G)^2+(p.c.B-color.B)^2
        if d<bestD then bestD=d; best=i end
    end
    return best
end
local function cyclePreset(color, dir)
    local idx=findPresetIndex(color, Config.ESP.Presets)+dir
    local n=#Config.ESP.Presets
    if idx<1 then idx=n end; if idx>n then idx=1 end
    return Config.ESP.Presets[idx].c
end
local function cycleAccent(color, dir)
    local idx=findPresetIndex(color, Config.GUI.AccentPresets)+dir
    local n=#Config.GUI.AccentPresets
    if idx<1 then idx=n end; if idx>n then idx=1 end
    return Config.GUI.AccentPresets[idx].c
end

local refreshBinds
local setAimToggle, setEspToggle, setFlyToggle, setInvisToggle
local setForceJumpToggle, setSpeedToggle, setHitboxToggle, setResizeToggle
local updateFly, updateForceJump, updateSpeed, updateHitbox, updateResize
local refreshTPList, applyAccent

local function listenForKey(titleObj, restoreTitle, onKey, onFinish)
    titleObj.Text="Нажми клавишу / кнопку мыши... (Esc — отмена)"
    task.wait(0.15)
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, gp)
        local isMouse=isMouseBind(input)
        if gp and not isMouse then return end
        local bind=nil
        if input.UserInputType==Enum.UserInputType.Keyboard then
            if input.KeyCode==Enum.KeyCode.Unknown then return end
            if input.KeyCode==Enum.KeyCode.Escape then
                conn:Disconnect(); titleObj.Text=restoreTitle
                if onFinish then onFinish() end; return
            end
            bind=input.KeyCode
        elseif isMouse then bind=input.UserInputType end
        if bind then
            onKey(bind); conn:Disconnect(); titleObj.Text=restoreTitle
            if refreshBinds then refreshBinds() end
            if onFinish then onFinish() end
        end
    end)
end

local getRootOf, getHeadOf
getRootOf = function(model)
    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
end
getHeadOf = function(model)
    return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
end

----------------------------------------------------------------
-- GLOBAL SETTINGS
----------------------------------------------------------------
local function refreshGlobalSettings()
    clearSettings(); currentPanel="global"
    settingsPanel.Visible=true; spTitle.Text="Меню"
    settingLabel("Прозрачность: "..string.format("%.2f", Config.GUI.Transparency))
    settingButton("+ 0.05", function()
        Config.GUI.Transparency=math.min(0.9, Config.GUI.Transparency+0.05)
        if main.Visible then main.BackgroundTransparency=Config.GUI.Transparency end
        refreshGlobalSettings() end)
    settingButton("- 0.05", function()
        Config.GUI.Transparency=math.max(0, Config.GUI.Transparency-0.05)
        if main.Visible then main.BackgroundTransparency=Config.GUI.Transparency end
        refreshGlobalSettings() end)
    settingLabel("Масштаб: "..string.format("%.2f", Config.GUI.Scale))
    settingButton("+ 0.05", function()
        Config.GUI.Scale=math.min(1.5, Config.GUI.Scale+0.05)
        mainScale.Scale=Config.GUI.Scale; refreshGlobalSettings() end)
    settingButton("- 0.05", function()
        Config.GUI.Scale=math.max(0.5, Config.GUI.Scale-0.05)
        mainScale.Scale=Config.GUI.Scale; refreshGlobalSettings() end)
    settingButton("Сброс (1.00)", function()
        Config.GUI.Scale=1; mainScale.Scale=1; refreshGlobalSettings() end)
    settingLabel("Цвет акцента")
    settingSwatch("тема: "..Config.GUI.AccentPresets[findPresetIndex(Config.GUI.Accent, Config.GUI.AccentPresets)].name,
        function() return Config.GUI.Accent end,
        function() Config.GUI.Accent=cycleAccent(Config.GUI.Accent,-1); applyAccent() end,
        function() Config.GUI.Accent=cycleAccent(Config.GUI.Accent,1); applyAccent() end)
    settingButton("Применить", function() applyAccent(); refreshGlobalSettings() end)
    settingLabel("Клавиша меню")
    settingButton("Bind: "..bindDisplayName(Config.GUI.ToggleBind), function()
        listenForKey(spTitle, "Меню", function(k) Config.GUI.ToggleBind=k end, refreshGlobalSettings) end)
    settingLabel("Звуки интерфейса")
    settingButton("Включены: "..(Config.Sounds.Enabled and "ON" or "OFF"), function()
        Config.Sounds.Enabled=not Config.Sounds.Enabled; refreshGlobalSettings() end)
    settingButton("Громкость: "..string.format("%.1f", Config.Sounds.ToggleVolume), function()
        Config.Sounds.ToggleVolume=math.min(2, Config.Sounds.ToggleVolume+0.2); refreshGlobalSettings() end)
    settingButton("Тест звука меню", function() playMenuOpen() end)
    settingButton("Тест toggle звука", function() playToggle() end)
    settingLabel("Эффект смерти")
    settingButton("Включён: "..(Config.Death.Enabled and "ON" or "OFF"), function()
        Config.Death.Enabled=not Config.Death.Enabled; refreshGlobalSettings() end)
    settingButton("Звук: "..(Config.Death.ShowSound and "ON" or "OFF"), function()
        Config.Death.ShowSound=not Config.Death.ShowSound; refreshGlobalSettings() end)
    settingButton("Тест звука смерти", function() playDeathSound() end)
    settingButton("Тест эффекта", function() deathActive=false; triggerDeathEffect() end)
end
local function openGlobalSettings()
    if currentPanel=="global" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshGlobalSettings() end
end
globalGearBtn.MouseButton1Click:Connect(openGlobalSettings)

function applyAccent()
    mStroke.Color=Config.GUI.Accent; sps.Color=Config.GUI.Accent
    fovStroke.Color=Config.GUI.Accent
    container.ScrollBarImageColor3=Config.GUI.Accent
    spContent.ScrollBarImageColor3=Config.GUI.Accent
    logoGlow.TextColor3=Config.GUI.Accent
    deathSub.TextColor3=Config.GUI.Accent
    for _,s in ipairs(shardList) do s.frame.BackgroundColor3=Config.GUI.Accent end
    for tName, tab in pairs(tabs) do
        if tab.content.Visible then tab.button.BackgroundColor3=Config.GUI.Accent end
    end
end

----------------------------------------------------------------
-- AIM SETTINGS
----------------------------------------------------------------
local function refreshAimSettings()
    clearSettings(); currentPanel="aim"
    settingsPanel.Visible=true; spTitle.Text="Aim"
    settingLabel("Кого выбирать")
    settingButton("Игроки: "..(Config.Aim.TargetPlayers and "ON" or "OFF"), function()
        Config.Aim.TargetPlayers=not Config.Aim.TargetPlayers; refreshAimSettings() end)
    settingButton("Боты: "..(Config.Aim.TargetBots and "ON" or "OFF"), function()
        Config.Aim.TargetBots=not Config.Aim.TargetBots; refreshAimSettings() end)
    settingLabel("Поведение")
    settingButton("AutoClick: "..(Config.Aim.AutoClick and "ON" or "OFF"), function()
        Config.Aim.AutoClick=not Config.Aim.AutoClick; refreshAimSettings() end)
    settingButton("FOV круг: "..(Config.Aim.ShowFOV and "ON" or "OFF"), function()
        Config.Aim.ShowFOV=not Config.Aim.ShowFOV; updateFovCircle(); refreshAimSettings() end)
    settingButton("Режим: "..(Config.Aim.UseMouse and "Mouse" or "Camera"), function()
        Config.Aim.UseMouse=not Config.Aim.UseMouse; refreshAimSettings() end)
    settingLabel("FOV: "..Config.Aim.FOV)
    settingButton("FOV +10", function() Config.Aim.FOV=math.min(600, Config.Aim.FOV+10); updateFovCircle(); refreshAimSettings() end)
    settingButton("FOV -10", function() Config.Aim.FOV=math.max(20, Config.Aim.FOV-10); updateFovCircle(); refreshAimSettings() end)
    settingLabel("Smoothness: "..string.format("%.2f", Config.Aim.Smoothness))
    settingButton("+ 0.05", function() Config.Aim.Smoothness=math.min(1, Config.Aim.Smoothness+0.05); refreshAimSettings() end)
    settingButton("- 0.05", function() Config.Aim.Smoothness=math.max(0.05, Config.Aim.Smoothness-0.05); refreshAimSettings() end)
    settingLabel("Дистанция: "..Config.Aim.MaxDistance)
    settingButton("+ 100", function() Config.Aim.MaxDistance=Config.Aim.MaxDistance+100; refreshAimSettings() end)
    settingButton("- 100", function() Config.Aim.MaxDistance=math.max(100, Config.Aim.MaxDistance-100); refreshAimSettings() end)
    settingLabel("Бинд")
    settingButton("Bind: "..bindDisplayName(Config.Aim.Bind), function()
        listenForKey(spTitle, "Aim", function(k) Config.Aim.Bind=k end, refreshAimSettings) end)
    settingButton("Сбросить", function() Config.Aim.Bind=nil; refreshBinds(); refreshAimSettings() end)
end
local function openAimSettings()
    if currentPanel=="aim" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshAimSettings() end
end
local aimRow = createRow(mainTab, "Aim Assist", "Наведение по видимой цели в FOV")
local _, setAimToggleRef = createToggle(aimRow, false, function(v) Config.Aim.Enabled=v; updateFovCircle() end)
setAimToggle = setAimToggleRef
createGear(aimRow, openAimSettings)

----------------------------------------------------------------
-- ESP SETTINGS
----------------------------------------------------------------
local function refreshESPSettings()
    clearSettings(); currentPanel="esp"
    settingsPanel.Visible=true; spTitle.Text="ESP"
    settingLabel("Цели")
    settingButton("Игроки: "..(Config.ESP.ShowPlayers and "ON" or "OFF"), function()
        Config.ESP.ShowPlayers=not Config.ESP.ShowPlayers; refreshESPSettings() end)
    settingButton("Боты: "..(Config.ESP.ShowBots and "ON" or "OFF"), function()
        Config.ESP.ShowBots=not Config.ESP.ShowBots; refreshESPSettings() end)
    settingLabel("Цвет")
    settingSwatch("цвет: "..Config.ESP.Presets[findPresetIndex(Config.ESP.Color, Config.ESP.Presets)].name,
        function() return Config.ESP.Color end,
        function() Config.ESP.Color=cyclePreset(Config.ESP.Color,-1) end,
        function() Config.ESP.Color=cyclePreset(Config.ESP.Color,1) end)
    settingLabel("Дистанция: "..Config.ESP.MaxDistance)
    settingButton("+ 100", function() Config.ESP.MaxDistance=Config.ESP.MaxDistance+100; refreshESPSettings() end)
    settingButton("- 100", function() Config.ESP.MaxDistance=math.max(100, Config.ESP.MaxDistance-100); refreshESPSettings() end)
    settingLabel("Бинд")
    settingButton("Bind: "..bindDisplayName(Config.ESP.Bind), function()
        listenForKey(spTitle, "ESP", function(k) Config.ESP.Bind=k end, refreshESPSettings) end)
    settingButton("Сбросить", function() Config.ESP.Bind=nil; refreshBinds(); refreshESPSettings() end)
end
local function openESPSettings()
    if currentPanel=="esp" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshESPSettings() end
end
local espRow = createRow(mainTab, "ESP", "Подсветка игроков/ботов")
local _, setEspToggleRef = createToggle(espRow, false, function(v) Config.ESP.Enabled=v end)
setEspToggle = setEspToggleRef
createGear(espRow, openESPSettings)

----------------------------------------------------------------
-- FLY
----------------------------------------------------------------
local function refreshFlySettings()
    clearSettings(); currentPanel="fly"
    settingsPanel.Visible=true; spTitle.Text="Fly"
    settingLabel("Fly Speed: "..Config.Fly.Speed)
    settingButton("+ 10", function() Config.Fly.Speed=Config.Fly.Speed+10; refreshFlySettings() end)
    settingButton("- 10", function() Config.Fly.Speed=math.max(10, Config.Fly.Speed-10); refreshFlySettings() end)
    settingButton("Noclip: "..(Config.Fly.Noclip and "ON" or "OFF"), function()
        Config.Fly.Noclip=not Config.Fly.Noclip; refreshFlySettings() end)
    settingLabel("Бинд")
    settingButton("Bind: "..bindDisplayName(Config.Fly.Bind), function()
        listenForKey(spTitle, "Fly", function(k) Config.Fly.Bind=k end, refreshFlySettings) end)
    settingButton("Сбросить", function() Config.Fly.Bind=nil; refreshBinds(); refreshFlySettings() end)
end
local function openFlySettings()
    if currentPanel=="fly" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshFlySettings() end
end
local flyRow = createRow(mainTab, "Fly + Noclip", "Полёт сквозь стены")
local _, setFlyToggleRef = createToggle(flyRow, false, function(v)
    Config.Fly.Enabled=v; if updateFly then updateFly() end end)
setFlyToggle = setFlyToggleRef
createGear(flyRow, openFlySettings)

----------------------------------------------------------------
-- SPEED
----------------------------------------------------------------
local function refreshSpeedSettings()
    clearSettings(); currentPanel="speed"
    settingsPanel.Visible=true; spTitle.Text="Speed"
    settingLabel("WalkSpeed: "..Config.Speed.Value)
    settingButton("+ 10", function() Config.Speed.Value=math.min(500, Config.Speed.Value+10); refreshSpeedSettings() end)
    settingButton("- 10", function() Config.Speed.Value=math.max(16, Config.Speed.Value-10); refreshSpeedSettings() end)
    settingButton("+ 50", function() Config.Speed.Value=math.min(500, Config.Speed.Value+50); refreshSpeedSettings() end)
    settingButton("- 50", function() Config.Speed.Value=math.max(16, Config.Speed.Value-50); refreshSpeedSettings() end)
    settingButton("Reset (16)", function() Config.Speed.Value=16; refreshSpeedSettings() end)
    settingLabel("Ползунок")
    settingSlider(16, 500, Config.Speed.Value, function(v) Config.Speed.Value=v end)
    settingLabel("Бинд")
    settingButton("Bind: "..bindDisplayName(Config.Speed.Bind), function()
        listenForKey(spTitle, "Speed", function(k) Config.Speed.Bind=k end, refreshSpeedSettings) end)
    settingButton("Сбросить", function() Config.Speed.Bind=nil; refreshBinds(); refreshSpeedSettings() end)
end
local function openSpeedSettings()
    if currentPanel=="speed" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshSpeedSettings() end
end
local speedRow = createRow(mainTab, "Speed", "Ускорение персонажа")
local _, setSpeedToggleRef = createToggle(speedRow, false, function(v)
    Config.Speed.Enabled=v; if updateSpeed then updateSpeed() end end)
setSpeedToggle = setSpeedToggleRef
createGear(speedRow, openSpeedSettings)

----------------------------------------------------------------
-- FORCE JUMP
----------------------------------------------------------------
local function refreshForceJumpSettings()
    clearSettings(); currentPanel="forcejump"
    settingsPanel.Visible=true; spTitle.Text="Force Jump"
    settingLabel("Статус: "..(Config.ForceJump.Enabled and "ВКЛ" or "ВЫКЛ"))
    settingButton(Config.ForceJump.Enabled and "Выключить" or "Включить", function()
        setForceJumpToggle(not Config.ForceJump.Enabled); refreshForceJumpSettings() end)
    settingLabel("Jump Power: "..Config.ForceJump.Power)
    settingButton("+ 10", function() Config.ForceJump.Power=math.min(500, Config.ForceJump.Power+10); refreshForceJumpSettings() end)
    settingButton("- 10", function() Config.ForceJump.Power=math.max(20, Config.ForceJump.Power-10); refreshForceJumpSettings() end)
    settingButton("Reset (100)", function() Config.ForceJump.Power=100; refreshForceJumpSettings() end)
    settingLabel("Бинд")
    settingButton("Bind: "..bindDisplayName(Config.ForceJump.Bind), function()
        listenForKey(spTitle, "Force Jump", function(k) Config.ForceJump.Bind=k end, refreshForceJumpSettings) end)
    settingButton("Сбросить", function() Config.ForceJump.Bind=nil; refreshBinds(); refreshForceJumpSettings() end)
end
local function openForceJumpSettings()
    if currentPanel=="forcejump" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshForceJumpSettings() end
end
local forceJumpRow = createRow(mainTab, "Force Jump", "Прыжок работает везде")
local _, setForceJumpToggleRef = createToggle(forceJumpRow, false, function(v)
    Config.ForceJump.Enabled=v; if updateForceJump then updateForceJump() end end)
setForceJumpToggle = setForceJumpToggleRef
createGear(forceJumpRow, openForceJumpSettings)

----------------------------------------------------------------
-- HITBOX
----------------------------------------------------------------
local function refreshHitboxSettings()
    clearSettings(); currentPanel="hitbox"
    settingsPanel.Visible=true; spTitle.Text="Hitbox"
    settingLabel("Статус: "..(Config.Hitbox.Enabled and "ВКЛ" or "ВЫКЛ"))
    settingButton(Config.Hitbox.Enabled and "Выключить" or "Включить", function()
        setHitboxToggle(not Config.Hitbox.Enabled); refreshHitboxSettings() end)
    settingLabel("Метод: тело персонажа")
    settingButton("Прозрачное тело: "..(Config.Hitbox.Transparency>0 and "ON" or "OFF"), function()
        Config.Hitbox.Transparency = (Config.Hitbox.Transparency>0) and 0 or 0.7
        updateHitbox(); refreshHitboxSettings() end)
    settingLabel("Размер: "..Config.Hitbox.Size)
    settingButton("+ 1", function() Config.Hitbox.Size=math.min(50, Config.Hitbox.Size+1); updateHitbox(); refreshHitboxSettings() end)
    settingButton("- 1", function() Config.Hitbox.Size=math.max(2, Config.Hitbox.Size-1); updateHitbox(); refreshHitboxSettings() end)
    settingButton("Reset (8)", function() Config.Hitbox.Size=8; updateHitbox(); refreshHitboxSettings() end)
    settingLabel("Ползунок размера")
    settingSlider(2, 50, Config.Hitbox.Size, function(v) Config.Hitbox.Size=v end)
    settingLabel("Прозрачность: "..string.format("%.2f", Config.Hitbox.Transparency))
    settingButton("Заметнее (+)", function() Config.Hitbox.Transparency=math.min(0.95, Config.Hitbox.Transparency+0.05); updateHitbox(); refreshHitboxSettings() end)
    settingButton("Прозрачнее (-)", function() Config.Hitbox.Transparency=math.max(0, Config.Hitbox.Transparency-0.05); updateHitbox(); refreshHitboxSettings() end)
    settingLabel("Цвет тела")
    settingSwatch("цвет: "..Config.ESP.Presets[findPresetIndex(Config.Hitbox.Color, Config.ESP.Presets)].name,
        function() return Config.Hitbox.Color end,
        function() Config.Hitbox.Color=cyclePreset(Config.Hitbox.Color,-1) end,
        function() Config.Hitbox.Color=cyclePreset(Config.Hitbox.Color,1) end)
    settingLabel("Цели")
    settingButton("Игроки: "..(Config.Hitbox.TargetPlayers and "ON" or "OFF"), function()
        Config.Hitbox.TargetPlayers=not Config.Hitbox.TargetPlayers; refreshHitboxSettings() end)
    settingButton("Боты: "..(Config.Hitbox.TargetBots and "ON" or "OFF"), function()
        Config.Hitbox.TargetBots=not Config.Hitbox.TargetBots; refreshHitboxSettings() end)
    settingLabel("Дистанция: "..Config.Hitbox.MaxDistance)
    settingButton("+ 500", function() Config.Hitbox.MaxDistance=Config.Hitbox.MaxDistance+500; refreshHitboxSettings() end)
    settingButton("- 500", function() Config.Hitbox.MaxDistance=math.max(500, Config.Hitbox.MaxDistance-500); refreshHitboxSettings() end)
    settingLabel("Бинд")
    settingButton("Bind: "..bindDisplayName(Config.Hitbox.Bind), function()
        listenForKey(spTitle, "Hitbox", function(k) Config.Hitbox.Bind=k end, refreshHitboxSettings) end)
    settingButton("Сбросить", function() Config.Hitbox.Bind=nil; refreshBinds(); refreshHitboxSettings() end)
end
local function openHitboxSettings()
    if currentPanel=="hitbox" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshHitboxSettings() end
end
local hitboxRow = createRow(mainTab, "Hitbox Expander", "Тело персонажа — попадания засчитываются")
local _, setHitboxToggleRef = createToggle(hitboxRow, false, function(v)
    Config.Hitbox.Enabled=v; if updateHitbox then updateHitbox() end end)
setHitboxToggle = setHitboxToggleRef
createGear(hitboxRow, openHitboxSettings)

----------------------------------------------------------------
-- RESIZE
----------------------------------------------------------------
local function refreshResizeSettings()
    clearSettings(); currentPanel="resize"
    settingsPanel.Visible=true; spTitle.Text="Resize"
    settingLabel("Статус: "..(Config.Resize.Enabled and "ВКЛ" or "ВЫКЛ"))
    settingButton(Config.Resize.Enabled and "Выключить" or "Включить", function()
        setResizeToggle(not Config.Resize.Enabled); refreshResizeSettings() end)
    settingLabel("Масштаб: "..string.format("%.2f", Config.Resize.Scale))
    settingButton("+ 0.05", function() Config.Resize.Scale=math.min(3, Config.Resize.Scale+0.05); updateResize(); refreshResizeSettings() end)
    settingButton("- 0.05", function() Config.Resize.Scale=math.max(0.1, Config.Resize.Scale-0.05); updateResize(); refreshResizeSettings() end)
    settingButton("Маленький (0.3)", function() Config.Resize.Scale=0.3; updateResize(); refreshResizeSettings() end)
    settingButton("Средний (0.6)", function() Config.Resize.Scale=0.6; updateResize(); refreshResizeSettings() end)
    settingButton("Норма (1.0)", function() Config.Resize.Scale=1.0; updateResize(); refreshResizeSettings() end)
    settingButton("Большой (1.5)", function() Config.Resize.Scale=1.5; updateResize(); refreshResizeSettings() end)
    settingLabel("Ползунок")
    settingSlider(0.1, 3, Config.Resize.Scale, function(v) Config.Resize.Scale=v end)
    settingLabel("Цели")
    settingButton("Все игроки: "..(Config.Resize.AllPlayers and "ON" or "OFF"), function()
        Config.Resize.AllPlayers=not Config.Resize.AllPlayers; updateResize(); refreshResizeSettings() end)
    settingLabel("Бинд")
    settingButton("Bind: "..bindDisplayName(Config.Resize.Bind), function()
        listenForKey(spTitle, "Resize", function(k) Config.Resize.Bind=k end, refreshResizeSettings) end)
    settingButton("Сбросить", function() Config.Resize.Bind=nil; refreshBinds(); refreshResizeSettings() end)
end
local function openResizeSettings()
    if currentPanel=="resize" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshResizeSettings() end
end
local resizeRow = createRow(mainTab, "Resize", "Уменьшение/увеличение персонажа")
local _, setResizeToggleRef = createToggle(resizeRow, false, function(v)
    Config.Resize.Enabled=v; if updateResize then updateResize() end end)
setResizeToggle = setResizeToggleRef
createGear(resizeRow, openResizeSettings)

----------------------------------------------------------------
-- INVIS (misc tab)
----------------------------------------------------------------
local invisActive=false
local invisScriptLoaded=false
local function destroyInvisGui()
    local parents = { LocalPlayer:FindFirstChild("PlayerGui"), CoreGui }
    for _, parent in ipairs(parents) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("ScreenGui") and child.Name~="Falid" and child.Name~="Falid_FOV" and child.Name~="Falid_Death" then
                    local n=string.lower(child.Name)
                    if string.find(n,"invis") or string.find(n,"universal") or string.find(n,"fe")
                        or string.find(n,"moon") or string.find(n,"paste") or string.find(n,"unknown") then
                        pcall(function() child:Destroy() end)
                    end
                end
            end
        end
    end
end
local function enableInvisExternal()
    if not invisScriptLoaded then
        pcall(function() loadstring(game:HttpGet(Config.InvisScriptURL))() end)
        invisScriptLoaded=true
    end
end
local invisRow = createRow(miscTab, "Invisible", "Вкл/выкл через внешний скрипт")
local _, setInvisToggleRef = createToggle(invisRow, false, function(v)
    Config.Invis.Enabled=v; invisActive=v
    if v then enableInvisExternal()
    else destroyInvisGui(); invisScriptLoaded=false end end)
setInvisToggle = setInvisToggleRef

----------------------------------------------------------------
-- WORLD TAB (кастомизация мира)
----------------------------------------------------------------
local weatherParts = {}
local worldParticles = {}
local function clearWeather() for _,p in ipairs(weatherParts) do pcall(function() p:Destroy() end) end weatherParts={} end
local function clearWorldParticles() for _,p in ipairs(worldParticles) do pcall(function() p:Destroy() end) end worldParticles={} end

local function spawnWeather()
    clearWeather()
    if not Config.World.WeatherEnabled then return end
    local amount = Config.World.WeatherAmount
    local wType = Config.World.WeatherType
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local origin = hrp.Position
    for i=1,amount do
        local p = Instance.new("Part")
        p.Size = Vector3.new(0.2, 0.2, 0.2)
        p.Shape = Enum.PartType.Ball
        p.Anchored = true
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Massless = true
        p.Material = Enum.Material.Neon
        if wType == "Rain" then
            p.Size = Vector3.new(0.1, 1.5, 0.1)
            p.Shape = Enum.PartType.Block
            p.Color = Color3.fromRGB(140,180,255)
            p.Transparency = 0.4
        elseif wType == "Snow" then
            p.Size = Vector3.new(0.3,0.3,0.3)
            p.Color = Color3.fromRGB(255,255,255)
            p.Transparency = 0.2
        elseif wType == "Leaves" then
            p.Size = Vector3.new(0.6,0.1,0.4)
            p.Shape = Enum.PartType.Block
            p.Color = Color3.fromRGB(200,120,40)
            p.Transparency = 0.1
        elseif wType == "Sparkles" then
            p.Size = Vector3.new(0.15,0.15,0.15)
            p.Color = Config.GUI.Accent
            p.Transparency = 0
        end
        local ang = math.random()*math.pi*2
        local rad = math.random()*30+5
        p.Position = origin + Vector3.new(math.cos(ang)*rad, math.random(20,50), math.sin(ang)*rad)
        p.Parent = workspace
        table.insert(weatherParts, p)
    end
    task.spawn(function()
        while Config.World.WeatherEnabled do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, p in ipairs(weatherParts) do
                    if p and p.Parent then
                        local ang = math.random()*math.pi*2
                        local rad = math.random()*25+5
                        p.CFrame = CFrame.new(hrp.Position + Vector3.new(math.cos(ang)*rad, math.random(15,45), math.sin(ang)*rad))
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

local function spawnWorldParticles()
    clearWorldParticles()
    if not Config.World.WorldParticles then return end
    local amount = Config.World.ParticleAmount
    local pType = Config.World.ParticleType
    for i=1,amount do
        local a = Instance.new("Attachment")
        a.Name = "Falid_Particle"
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then a.Parent = hrp else a.Parent = workspace.Terrain end
        local pe = Instance.new("ParticleEmitter")
        pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        pe.Rate = 20
        pe.Lifetime = NumberRange.new(1.5, 3)
        pe.Speed = NumberRange.new(2, 6)
        pe.SpreadAngle = Vector2.new(180,180)
        pe.Rotation = NumberRange.new(0, 360)
        pe.RotSpeed = NumberRange.new(-30, 30)
        pe.Size = NumberSequence.new(0.5)
        pe.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        })
        if pType == "Sparkles" then
            pe.Color = ColorSequence.new(Config.GUI.Accent)
            pe.Size = NumberSequence.new(0.3)
        elseif pType == "Hearts" then
            pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            pe.Color = ColorSequence.new(Color3.fromRGB(255, 80, 140))
            pe.Size = NumberSequence.new(0.6)
        elseif pType == "Stars" then
            pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            pe.Color = ColorSequence.new(Color3.fromRGB(255, 240, 100))
            pe.Size = NumberSequence.new(0.5)
        end
        pe.Parent = a
        table.insert(worldParticles, a)
    end
    task.spawn(function()
        while Config.World.WorldParticles do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, a in ipairs(worldParticles) do
                    if a and a.Parent and a.Parent ~= hrp then pcall(function() a.Parent = hrp end) end
                end
            end
            task.wait(1)
        end
    end)
end

local function applyWorldTime()
    if Config.World.TimeEnabled then
        pcall(function() Lighting.ClockTime = Config.World.ClockTime end)
    end
end
local function applyWorldFog()
    pcall(function()
        if Config.World.FogEnabled then
            Lighting.FogColor = Config.World.FogColor
            Lighting.FogStart = Config.World.FogStart
            Lighting.FogEnd = Config.World.FogEnd
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        end
    end)
end
local function applyBrightness()
    if Config.World.BrightnessEnabled then
        pcall(function() Lighting.Brightness = Config.World.Brightness end)
    end
end

local function refreshWorldSettings()
    clearSettings(); currentPanel="world"
    settingsPanel.Visible=true; spTitle.Text="World"
    settingLabel("Время суток")
    settingButton("Активно: "..(Config.World.TimeEnabled and "ON" or "OFF"), function()
        Config.World.TimeEnabled=not Config.World.TimeEnabled; applyWorldTime(); refreshWorldSettings() end)
    settingButton("Время: "..string.format("%.1f", Config.World.ClockTime), function()
        Config.World.ClockTime=(Config.World.ClockTime+2)%24; applyWorldTime(); refreshWorldSettings() end)
    settingButton("Утро (7)", function() Config.World.ClockTime=7; applyWorldTime(); refreshWorldSettings() end)
    settingButton("День (14)", function() Config.World.ClockTime=14; applyWorldTime(); refreshWorldSettings() end)
    settingButton("Вечер (18)", function() Config.World.ClockTime=18; applyWorldTime(); refreshWorldSettings() end)
    settingButton("Ночь (0)", function() Config.World.ClockTime=0; applyWorldTime(); refreshWorldSettings() end)
    settingLabel("Ползунок времени")
    settingSlider(0, 24, Config.World.ClockTime, function(v) Config.World.ClockTime=v; applyWorldTime() end)
    settingLabel("Туман")
    settingButton("Активно: "..(Config.World.FogEnabled and "ON" or "OFF"), function()
        Config.World.FogEnabled=not Config.World.FogEnabled; applyWorldFog(); refreshWorldSettings() end)
    settingButton("Дистанция: "..Config.World.FogEnd, function()
        Config.World.FogEnd=math.min(5000, Config.World.FogEnd+200); applyWorldFog(); refreshWorldSettings() end)
    settingButton("Уменьшить", function()
        Config.World.FogEnd=math.max(100, Config.World.FogEnd-200); applyWorldFog(); refreshWorldSettings() end)
    settingLabel("Яркость")
    settingButton("Активно: "..(Config.World.BrightnessEnabled and "ON" or "OFF"), function()
        Config.World.BrightnessEnabled=not Config.World.BrightnessEnabled; applyBrightness(); refreshWorldSettings() end)
    settingButton("Яркость: "..Config.World.Brightness, function()
        Config.World.Brightness=math.min(5, Config.World.Brightness+0.5); applyBrightness(); refreshWorldSettings() end)
    settingButton("Уменьшить", function()
        Config.World.Brightness=math.max(0, Config.World.Brightness-0.5); applyBrightness(); refreshWorldSettings() end)
    settingLabel("Погода")
    settingButton("Активно: "..(Config.World.WeatherEnabled and "ON" or "OFF"), function()
        Config.World.WeatherEnabled=not Config.World.WeatherEnabled; spawnWeather(); refreshWorldSettings() end)
    settingButton("Тип: "..Config.World.WeatherType, function()
        local list = {"Rain","Snow","Leaves","Sparkles"}
        for i,t in ipairs(list) do
            if t==Config.World.WeatherType then
                Config.World.WeatherType = list[i%#list+1]; break
            end
        end
        spawnWeather(); refreshWorldSettings() end)
    settingButton("Кол-во: "..Config.World.WeatherAmount, function()
        Config.World.WeatherAmount=math.min(200, Config.World.WeatherAmount+10); spawnWeather(); refreshWorldSettings() end)
    settingButton("Уменьшить", function()
        Config.World.WeatherAmount=math.max(10, Config.World.WeatherAmount-10); spawnWeather(); refreshWorldSettings() end)
    settingLabel("Частицы вокруг тебя")
    settingButton("Активно: "..(Config.World.WorldParticles and "ON" or "OFF"), function()
        Config.World.WorldParticles=not Config.World.WorldParticles; spawnWorldParticles(); refreshWorldSettings() end)
    settingButton("Тип: "..Config.World.ParticleType, function()
        local list = {"Sparkles","Hearts","Stars"}
        for i,t in ipairs(list) do
            if t==Config.World.ParticleType then
                Config.World.ParticleType = list[i%#list+1]; break
            end
        end
        spawnWorldParticles(); refreshWorldSettings() end)
end
local function openWorldSettings()
    if currentPanel=="world" and settingsPanel.Visible then settingsPanel.Visible=false
    else refreshWorldSettings() end
end

-- World rows
local timeRow = createRow(worldTab, "Время суток", "Day / night — меняй время в игре")
local _, setTimeToggleRef = createToggle(timeRow, false, function(v)
    Config.World.TimeEnabled=v; applyWorldTime() end)
createGear(timeRow, openWorldSettings)

local fogRow = createRow(worldTab, "Туман", "Изменить дальность и цвет тумана")
local _, setFogToggleRef = createToggle(fogRow, false, function(v)
    Config.World.FogEnabled=v; applyWorldFog() end)
createGear(fogRow, openWorldSettings)

local brightRow = createRow(worldTab, "Яркость мира", "Освещение сцены")
local _, setBrightToggleRef = createToggle(brightRow, false, function(v)
    Config.World.BrightnessEnabled=v; applyBrightness() end)
createGear(brightRow, openWorldSettings)

local weatherRow = createRow(worldTab, "Погода", "Rain / Snow / Leaves / Sparkles")
local _, setWeatherToggleRef = createToggle(weatherRow, false, function(v)
    Config.World.WeatherEnabled=v; spawnWeather() end)
createGear(weatherRow, openWorldSettings)

local worldPartRow = createRow(worldTab, "Частицы вокруг тебя", "Sparkles / Hearts / Stars — летят за тобой")
local _, setWorldPartToggleRef = createToggle(worldPartRow, false, function(v)
    Config.World.WorldParticles=v; spawnWorldParticles() end)
createGear(worldPartRow, openWorldSettings)

----------------------------------------------------------------
-- HITBOX ENGINE
----------------------------------------------------------------
local hitboxSaved = {}
local function applyHitbox(model)
    if not model or not model:IsA("Model") then return end
    if model == LocalPlayer.Character then return end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    local s = Config.Hitbox.Size
    local scale = math.max(1, s/4)
    if not hitboxSaved[model] then
        hitboxSaved[model] = { parts={}, hipHeight=hum.HipHeight }
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                hitboxSaved[model].parts[p]={ size=p.Size, canCollide=p.CanCollide,
                    transparency=p.Transparency, material=p.Material }
            end
        end
    end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            local saved = hitboxSaved[model].parts[p]
            if saved then
                pcall(function()
                    p.Size=Vector3.new(saved.size.X*scale, saved.size.Y*scale, saved.size.Z*scale)
                    p.CanCollide=false; p.Massless=true; p.CanTouch=true; p.CanQuery=true
                    if Config.Hitbox.Transparency > 0 then
                        p.Transparency=Config.Hitbox.Transparency
                        p.Material=Enum.Material.ForceField
                        p.Color=Config.Hitbox.Color
                    else
                        p.Transparency=saved.transparency
                        p.Material=saved.material
                    end
                end)
            end
        end
    end
    pcall(function() hum.HipHeight=0 end)
end
local function removeHitbox(model)
    local saved = hitboxSaved[model]
    if saved then
        for p,info in pairs(saved.parts) do
            if p and p.Parent then
                pcall(function()
                    p.Size=info.size; p.CanCollide=info.canCollide
                    p.Transparency=info.transparency; p.Material=info.material
                end)
            end
        end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.HipHeight=saved.hipHeight end) end
    end
    hitboxSaved[model]=nil
end
local function clearAllHitboxes() for m in pairs(hitboxSaved) do removeHitbox(m) end end
local function hitboxTick()
    if not Config.Hitbox.Enabled then
        if next(hitboxSaved) then clearAllHitboxes() end
        return
    end
    if LocalPlayer.Character and hitboxSaved[LocalPlayer.Character] then removeHitbox(LocalPlayer.Character) end
    local char = LocalPlayer.Character
    local myRoot = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    if not myRoot then return end
    local maxD = Config.Hitbox.MaxDistance
    local found = {}
    if Config.Hitbox.TargetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")
                if root and (root.Position-myRoot.Position).Magnitude<=maxD then
                    applyHitbox(plr.Character); found[plr.Character]=true
                end
            end
        end
    end
    if Config.Hitbox.TargetBots then
        local function scan(parent, depth)
            if depth>4 then return end
            for _, obj in ipairs(parent:GetChildren()) do
                if obj:IsA("Model") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and not Players:GetPlayerFromCharacter(obj) and obj~=LocalPlayer.Character then
                        local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                        if root and (root.Position-myRoot.Position).Magnitude<=maxD then
                            applyHitbox(obj); found[obj]=true
                        end
                    else scan(obj, depth+1) end
                elseif obj:IsA("Folder") then scan(obj, depth+1) end
            end
        end
        scan(workspace, 1)
    end
    for model in pairs(hitboxSaved) do
        if not model.Parent or not model:FindFirstChildOfClass("Humanoid") or not found[model] then
            removeHitbox(model)
        end
    end
end
local hitboxConn=nil
updateHitbox = function()
    if Config.Hitbox.Enabled then
        if not hitboxConn then
            hitboxConn = RunService.Heartbeat:Connect(function() pcall(hitboxTick) end)
        end
        pcall(hitboxTick)
    else
        if hitboxConn then hitboxConn:Disconnect(); hitboxConn=nil end
        clearAllHitboxes()
    end
end

----------------------------------------------------------------
-- SPEED ENGINE
----------------------------------------------------------------
local speedRunning=false; local speedConns={}
local function speedEnforce()
    if not Config.Speed.Enabled then return end
    local char=LocalPlayer.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return end
    if hum.WalkSpeed~=Config.Speed.Value then pcall(function() hum.WalkSpeed=Config.Speed.Value end) end
end
local function hookHumanoidSpeed(hum)
    if not hum then return end
    table.insert(speedConns, hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if Config.Speed.Enabled then pcall(function() hum.WalkSpeed=Config.Speed.Value end) end
    end))
end
local function startSpeed()
    if speedRunning then return end
    speedRunning=true
    for _,c in ipairs(speedConns) do pcall(function() c:Disconnect() end) end
    speedConns={}
    table.insert(speedConns, RunService.Heartbeat:Connect(speedEnforce))
    table.insert(speedConns, RunService.Stepped:Connect(speedEnforce))
    table.insert(speedConns, RunService.RenderStepped:Connect(speedEnforce))
    pcall(function() RunService:BindToRenderStep("Falid_Speed", Enum.RenderPriority.Character.Value+10, speedEnforce) end)
    local char=LocalPlayer.Character
    if char then hookHumanoidSpeed(char:FindFirstChildOfClass("Humanoid")) end
    table.insert(speedConns, LocalPlayer.CharacterAdded:Connect(function(c)
        task.wait(0.3)
        if Config.Speed.Enabled then hookHumanoidSpeed(c:FindFirstChildOfClass("Humanoid")); speedEnforce() end
    end))
    speedEnforce()
end
local function stopSpeed()
    speedRunning=false
    for _,c in ipairs(speedConns) do pcall(function() c:Disconnect() end) end
    speedConns={}
    pcall(function() RunService:UnbindFromRenderStep("Falid_Speed") end)
    local char=LocalPlayer.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.WalkSpeed=16 end) end
    end
end
updateSpeed = function() if Config.Speed.Enabled then startSpeed() else stopSpeed() end end

----------------------------------------------------------------
-- FORCE JUMP ENGINE
----------------------------------------------------------------
local forceJumpRunning=false; local forceJumpConns={}; local forceJumpSaved=nil
local function forceJumpApply()
    if not Config.ForceJump.Enabled then return end
    local char=LocalPlayer.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return end
    if not forceJumpSaved then
        forceJumpSaved={ UseJumpPower=hum.UseJumpPower, JumpPower=hum.JumpPower, JumpHeight=hum.JumpHeight }
    end
    pcall(function()
        hum.UseJumpPower=true
        hum.JumpPower=Config.ForceJump.Power
        hum.JumpHeight=Config.ForceJump.Power*0.5
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
    end)
end
local function forceJumpDoJump()
    if not Config.ForceJump.Enabled or isMenuOpen() then return end
    local char=LocalPlayer.Character
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
    if not hum or not root or hum.Health<=0 then return end
    pcall(function()
        hum.Jump=true
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        local v=root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity=Vector3.new(v.X, math.max(v.Y, Config.ForceJump.Power), v.Z)
    end)
end
local function startForceJump()
    if forceJumpRunning then return end
    forceJumpRunning=true
    for _,c in ipairs(forceJumpConns) do pcall(function() c:Disconnect() end) end
    forceJumpConns={}
    table.insert(forceJumpConns, RunService.Stepped:Connect(forceJumpApply))
    table.insert(forceJumpConns, RunService.Heartbeat:Connect(forceJumpApply))
    table.insert(forceJumpConns, UserInputService.JumpRequest:Connect(forceJumpDoJump))
    forceJumpApply()
end
local function stopForceJump()
    forceJumpRunning=false
    for _,c in ipairs(forceJumpConns) do pcall(function() c:Disconnect() end) end
    forceJumpConns={}
    local char=LocalPlayer.Character
    if char then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function()
            if forceJumpSaved then
                hum.UseJumpPower=forceJumpSaved.UseJumpPower
                hum.JumpPower=forceJumpSaved.JumpPower
                hum.JumpHeight=forceJumpSaved.JumpHeight
            else
                hum.UseJumpPower=true; hum.JumpPower=50; hum.JumpHeight=7.2
            end
        end) end
    end
    forceJumpSaved=nil
end
updateForceJump = function() if Config.ForceJump.Enabled then startForceJump() else stopForceJump() end end

----------------------------------------------------------------
-- RESIZE ENGINE
----------------------------------------------------------------
local resizeConns={}; local resizeRunning=false; local resizeSaved={}
local function saveCharacterSize(model)
    if resizeSaved[model] then return end
    resizeSaved[model]={ parts={} }
    for _,p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then resizeSaved[model].parts[p]=p.Size end
    end
end
local function applyResize(model, scale)
    if not model or not model:IsA("Model") then return end
    saveCharacterSize(model)
    for _,p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then
            local orig=resizeSaved[model].parts[p]
            if orig then pcall(function()
                p.Size=Vector3.new(orig.X*scale, orig.Y*scale, orig.Z*scale)
                p.Massless=true
            end) end
        end
    end
    local hum=model:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.HipHeight=2*scale end) end
end
local function restoreResize(model)
    if not model then return end
    local saved=resizeSaved[model]
    if saved then
        for p,size in pairs(saved.parts) do
            if p and p.Parent then pcall(function() p.Size=size end) end
        end
    end
    resizeSaved[model]=nil
end
local function resizeTick()
    if not Config.Resize.Enabled then
        if next(resizeSaved) then for m in pairs(resizeSaved) do restoreResize(m) end end
        return
    end
    local scale=Config.Resize.Scale
    if LocalPlayer.Character then applyResize(LocalPlayer.Character, scale) end
    if Config.Resize.AllPlayers then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then applyResize(plr.Character, scale) end
        end
    elseif next(resizeSaved) then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character and resizeSaved[plr.Character] then restoreResize(plr.Character) end
        end
    end
end
updateResize = function()
    if Config.Resize.Enabled then
        if not resizeRunning then
            resizeRunning=true
            table.insert(resizeConns, RunService.Heartbeat:Connect(function() pcall(resizeTick) end))
        end
        pcall(resizeTick)
    else
        resizeRunning=false
        for _,c in ipairs(resizeConns) do pcall(function() c:Disconnect() end) end
        resizeConns={}
        for m in pairs(resizeSaved) do restoreResize(m) end
    end
end

----------------------------------------------------------------
-- FLY
----------------------------------------------------------------
local flyActive=false; local flyConn=nil
local function getRoot()
    local char=LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"),
           char:FindFirstChildOfClass("Humanoid")
end
local function setNoclipState(state)
    local char=LocalPlayer.Character
    if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p.CanCollide=not state end) end
    end
end
local function startFly()
    if flyActive then return end
    local root,hum=getRoot()
    if not root then return end
    flyActive=true
    if hum then hum.PlatformStand=true end
    flyConn=RunService.Heartbeat:Connect(function(dt)
        if not Config.Fly.Enabled then return end
        local root,hum=getRoot()
        if not root then return end
        if hum and not hum.PlatformStand then hum.PlatformStand=true end
        local dir=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir=dir+Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir=dir-Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir=dir-Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir=dir+Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.yAxis end
        if dir.Magnitude>0 then root.CFrame=root.CFrame+dir.Unit*Config.Fly.Speed*dt end
        root.AssemblyLinearVelocity=Vector3.zero
        root.AssemblyAngularVelocity=Vector3.zero
        if Config.Fly.Noclip then setNoclipState(true) end
    end)
end
local function stopFly()
    if not flyActive then return end
    flyActive=false
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    local root,hum=getRoot()
    if root then
        root.AssemblyLinearVelocity=Vector3.zero
        root.AssemblyAngularVelocity=Vector3.zero
    end
    if hum then hum.PlatformStand=false end
    if Config.Fly.Noclip then setNoclipState(false) end
end
updateFly = function() if Config.Fly.Enabled then startFly() else stopFly() end end

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------
local highlights={}
local function addESP(model)
    if not model or not model:IsA("Model") then return end
    if model==LocalPlayer.Character then return end
    if highlights[model] and highlights[model].Parent then return end
    local hum=model:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local c=Config.ESP.Color
    local h=Instance.new("Highlight")
    h.Name="Falid_ESP"; h.FillColor=c; h.OutlineColor=c
    h.FillTransparency=0.65; h.OutlineTransparency=0
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee=model; h.Parent=model
    highlights[model]=h
end
local function removeESP(model)
    local h=highlights[model]
    if h then pcall(function() h:Destroy() end); highlights[model]=nil end
end
local function clearAllESP() for m in pairs(highlights) do removeESP(m) end end
local function collectBotsFrom(container, depth, maxDepth, out)
    if depth>maxDepth then return end
    for _,obj in ipairs(container:GetChildren()) do
        if obj:IsA("Model") then
            local hum=obj:FindFirstChildOfClass("Humanoid")
            if hum and not Players:GetPlayerFromCharacter(obj) then out[#out+1]=obj
            else collectBotsFrom(obj, depth+1, maxDepth, out) end
        elseif obj:IsA("Folder") then collectBotsFrom(obj, depth+1, maxDepth, out) end
    end
end
local function collectBots() local out={}; collectBotsFrom(workspace,1,4,out); return out end
local function espTick()
    if not Config.ESP.Enabled then if next(highlights) then clearAllESP() end return end
    if LocalPlayer.Character and highlights[LocalPlayer.Character] then removeESP(LocalPlayer.Character) end
    local char=LocalPlayer.Character
    local myRoot=char and getRootOf(char)
    if not myRoot then return end
    local maxD=Config.ESP.MaxDistance
    local found={}
    if Config.ESP.ShowPlayers then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then
                local root=getRootOf(plr.Character)
                if root and (root.Position-myRoot.Position).Magnitude<=maxD then
                    addESP(plr.Character); found[plr.Character]=true
                end
            end
        end
    end
    if Config.ESP.ShowBots then
        for _,model in ipairs(collectBots()) do
            if model~=LocalPlayer.Character then
                local root=getRootOf(model)
                local hum=model:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health>0 and (root.Position-myRoot.Position).Magnitude<=maxD then
                    addESP(model); found[model]=true
                end
            end
        end
    end
    for model,h in pairs(highlights) do
        if not model.Parent or not model:FindFirstChildOfClass("Humanoid") then removeESP(model)
        elseif found[model] then h.FillColor=Config.ESP.Color; h.OutlineColor=Config.ESP.Color
        else removeESP(model) end
    end
end
task.spawn(function() while task.wait(0.1) do pcall(espTick) end end)

----------------------------------------------------------------
-- AIM
----------------------------------------------------------------
local function hasLineOfSight(targetPart, targetModel)
    local origin=Camera.CFrame.Position
    local direction=targetPart.Position-origin
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={ LocalPlayer.Character, Camera }
    params.IgnoreWater=true
    local result=workspace:Raycast(origin, direction, params)
    if not result then return true end
    local hit=result.Instance
    if hit==targetPart then return true end
    if targetModel and (hit:IsDescendantOf(targetModel) or hit==targetModel) then return true end
    if targetPart.Parent and hit:IsDescendantOf(targetPart.Parent) then return true end
    return false
end
local function collectTargets()
    local list, seen={}, {}
    local function push(model)
        if seen[model] or model==LocalPlayer.Character then return end
        seen[model]=true
        local hum=model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then return end
        local root=getRootOf(model); local head=getHeadOf(model)
        if not root or not head then return end
        list[#list+1]={ model=model, root=root, aim=head }
    end
    if Config.Aim.TargetPlayers then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character then push(plr.Character) end
        end
    end
    if Config.Aim.TargetBots then for _,m in ipairs(collectBots()) do push(m) end end
    return list
end
local function getAimTarget()
    local char=LocalPlayer.Character
    local myRoot=char and getRootOf(char)
    if not myRoot then return nil end
    local best, bestScreenDist=nil, math.huge
    local center=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local fov=Config.Aim.FOV; local maxD=Config.Aim.MaxDistance
    for _,entry in ipairs(collectTargets()) do
        local worldDist=(entry.root.Position-myRoot.Position).Magnitude
        if worldDist<=maxD then
            local sp=Camera:WorldToViewportPoint(entry.aim.Position)
            if sp.Z>0 then
                local screenVec=Vector2.new(sp.X, sp.Y)
                local screenDist=(screenVec-center).Magnitude
                if screenDist<=fov and screenDist<bestScreenDist then
                    if hasLineOfSight(entry.aim, entry.model) then
                        bestScreenDist=screenDist; best=entry.aim
                    end
                end
            end
        end
    end
    return best
end
local function moveCameraTo(target)
    local desired=CFrame.lookAt(Camera.CFrame.Position, target.Position)
    Camera.CFrame=Camera.CFrame:Lerp(desired, Config.Aim.Smoothness)
end
local function moveMouseTo(target)
    local sp=Camera:WorldToViewportPoint(target.Position)
    local center=Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local dx=sp.X-center.X; local dy=sp.Y-center.Y
    local k=math.clamp(Config.Aim.Smoothness, 0.05, 1)
    if mousemoverel then mousemoverel(dx*k, dy*k)
    elseif Input and Input.MouseMove then Input.MouseMove(dx*k, dy*k)
    else Mouse.X=Mouse.X+dx*k; Mouse.Y=Mouse.Y+dy*k end
end
local aimAccum=0
local function aimStep(dt)
    if not Config.Aim.Enabled then return end
    aimAccum=aimAccum+dt
    if aimAccum<0.016 then return end
    aimAccum=0
    local target=getAimTarget()
    if not target then return end
    if Config.Aim.UseMouse then moveMouseTo(target) else moveCameraTo(target) end
end
pcall(function()
    RunService:BindToRenderStep("Falid_Aim_Cam", Enum.RenderPriority.Camera.Value+1, function(dt)
        if Config.Aim.UseMouse then return end
        aimStep(dt)
    end)
end)
RunService.RenderStepped:Connect(function(dt) if not Config.Aim.UseMouse then return end; aimStep(dt) end)

----------------------------------------------------------------
-- TELEPORT
----------------------------------------------------------------
local tpScroll=Instance.new("ScrollingFrame")
tpScroll.BackgroundTransparency=1; tpScroll.BorderSizePixel=0
tpScroll.Size=UDim2.new(1,0,1,0); tpScroll.CanvasSize=UDim2.new(0,0,0,0)
tpScroll.ScrollBarThickness=6; tpScroll.ScrollBarImageColor3=Config.GUI.Accent
tpScroll.Parent=tpTab
pcall(function() tpScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y end)
local tpLayout=Instance.new("UIListLayout")
tpLayout.Padding=UDim.new(0,6); tpLayout.Parent=tpScroll
local tpBindTargets, tpBindConnections={}, {}
local function teleportTo(player)
    if not player or not player.Character then return end
    local myChar=LocalPlayer.Character
    local myRoot=myChar and getRootOf(myChar)
    local targetRoot=getRootOf(player.Character)
    if not myRoot or not targetRoot then return end
    pcall(function() myRoot.CFrame=CFrame.new(targetRoot.Position+Vector3.new(0,3,3)) end)
    showToast("Телепорт → "..player.Name, Config.GUI.Accent)
end
local function createPlayerRow(player)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,44)
    row.BackgroundColor3=Color3.fromRGB(30,30,40)
    row.BorderSizePixel=0; row.Parent=tpScroll
    Instance.new("UICorner", row).CornerRadius=UDim.new(0,8)
    local name=Instance.new("TextLabel")
    name.BackgroundTransparency=1; name.Position=UDim2.fromOffset(12,0)
    name.Size=UDim2.new(1,-100,1,0); name.Font=Enum.Font.GothamMedium
    name.Text=player.Name..(tpBindTargets[player] and (" ["..bindDisplayName(tpBindTargets[player]).."]") or "")
    name.TextSize=13; name.TextColor3=Color3.fromRGB(230,230,245)
    name.TextXAlignment=Enum.TextXAlignment.Left; name.Parent=row
    local tpBtn=Instance.new("TextButton")
    tpBtn.Size=UDim2.fromOffset(40,28); tpBtn.Position=UDim2.new(1,-84,0.5,-14)
    tpBtn.BackgroundColor3=Config.GUI.Accent
    tpBtn.Text="TP"; tpBtn.Font=Enum.Font.GothamBold
    tpBtn.TextSize=12; tpBtn.TextColor3=Color3.fromRGB(255,255,255); tpBtn.Parent=row
    Instance.new("UICorner", tpBtn).CornerRadius=UDim.new(0,6)
    tpBtn.MouseButton1Click:Connect(function() teleportTo(player) end)
    local gear=Instance.new("TextButton")
    gear.Size=UDim2.fromOffset(28,28); gear.Position=UDim2.new(1,-38,0.5,-14)
    gear.BackgroundTransparency=1; gear.Text="⚙"
    gear.Font=Enum.Font.GothamBold; gear.TextSize=18
    gear.TextColor3=Color3.fromRGB(170,170,185); gear.Parent=row
    gear.MouseButton1Click:Connect(function()
        local orig=spTitle.Text
        spTitle.Text="Клавиша для "..player.Name
        settingsPanel.Visible=true
        task.wait(0.15)
        local conn
        conn=UserInputService.InputBegan:Connect(function(input, gp)
            local isMouse=isMouseBind(input)
            if gp and not isMouse then return end
            local bind=nil
            if input.UserInputType==Enum.UserInputType.Keyboard then
                if input.KeyCode==Enum.KeyCode.Unknown then return end
                if input.KeyCode==Enum.KeyCode.Escape then conn:Disconnect(); spTitle.Text=orig return end
                bind=input.KeyCode
            elseif isMouse then bind=input.UserInputType end
            if bind then
                if tpBindConnections[player] then tpBindConnections[player]:Disconnect(); tpBindConnections[player]=nil end
                tpBindTargets[player]=bind
                conn:Disconnect(); spTitle.Text=orig
                tpBindConnections[player]=ContextActionService:BindActionAtPriority(
                    "Falid_TP_"..player.UserId,
                    function(_, state)
                        if state==Enum.UserInputState.Begin then teleportTo(player) end
                        return Enum.ContextActionResult.Pass
                    end, false, Enum.ContextActionPriority.High.Value, bind)
                refreshTPList()
            end
        end)
    end)
end
function refreshTPList()
    for _,v in ipairs(tpScroll:GetChildren()) do
        if v:IsA("GuiObject") then v:Destroy() end
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LocalPlayer then createPlayerRow(plr) end
    end
end
Players.PlayerAdded:Connect(function() task.wait(0.2); refreshTPList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshTPList() end)
refreshTPList()
switchTab("main")

----------------------------------------------------------------
-- KEYBINDS
----------------------------------------------------------------
local function makeHandler(fn)
    return function(_, state)
        if state==Enum.UserInputState.Begin then fn() end
        return Enum.ContextActionResult.Pass
    end
end
function refreshBinds()
    for _,n in ipairs({"Falid_Toggle","Falid_Aim","Falid_ESP","Falid_Fly","Falid_ForceJump","Falid_Speed","Falid_Hitbox","Falid_Resize"}) do
        ContextActionService:UnbindAction(n)
    end
    if Config.GUI.ToggleBind then
        ContextActionService:BindActionAtPriority("Falid_Toggle", makeHandler(function()
            main.Visible = not main.Visible
            if main.Visible then playMenuOpen() else playMenuOpen() end
            if not main.Visible then settingsPanel.Visible=false end
        end), false, Enum.ContextActionPriority.High.Value, Config.GUI.ToggleBind)
    end
    if Config.Aim.Bind then
        ContextActionService:BindActionAtPriority("Falid_Aim", makeHandler(function()
            setAimToggle(not Config.Aim.Enabled); playToggle() end), false, Enum.ContextActionPriority.High.Value, Config.Aim.Bind)
    end
    if Config.ESP.Bind then
        ContextActionService:BindActionAtPriority("Falid_ESP", makeHandler(function()
            setEspToggle(not Config.ESP.Enabled); playToggle() end), false, Enum.ContextActionPriority.High.Value, Config.ESP.Bind)
    end
    if Config.Fly.Bind then
        ContextActionService:BindActionAtPriority("Falid_Fly", makeHandler(function()
            setFlyToggle(not Config.Fly.Enabled); playToggle() end), false, Enum.ContextActionPriority.High.Value, Config.Fly.Bind)
    end
    if Config.ForceJump.Bind then
        ContextActionService:BindActionAtPriority("Falid_ForceJump", makeHandler(function()
            setForceJumpToggle(not Config.ForceJump.Enabled); playToggle() end), false, Enum.ContextActionPriority.High.Value, Config.ForceJump.Bind)
    end
    if Config.Speed.Bind then
        ContextActionService:BindActionAtPriority("Falid_Speed", makeHandler(function()
            setSpeedToggle(not Config.Speed.Enabled); playToggle() end), false, Enum.ContextActionPriority.High.Value, Config.Speed.Bind)
    end
    if Config.Hitbox.Bind then
        ContextActionService:BindActionAtPriority("Falid_Hitbox", makeHandler(function()
            setHitboxToggle(not Config.Hitbox.Enabled); playToggle() end), false, Enum.ContextActionPriority.High.Value, Config.Hitbox.Bind)
    end
    if Config.Resize.Bind then
        ContextActionService:BindActionAtPriority("Falid_Resize", makeHandler(function()
            setResizeToggle(not Config.Resize.Enabled); playToggle() end), false, Enum.ContextActionPriority.High.Value, Config.Resize.Bind)
    end
end
refreshBinds()

----------------------------------------------------------------
-- RESPAWN
----------------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    forceJumpSaved=nil
    clearAllHitboxes()
    resizeSaved={}
    if Config.ForceJump.Enabled then stopForceJump(); task.wait(0.1); startForceJump() end
    stopFly(); if Config.Fly.Enabled then task.wait(0.1); startFly() end
    stopSpeed(); if Config.Speed.Enabled then task.wait(0.1); startSpeed() end
    if Config.Hitbox.Enabled then task.wait(0.1); updateHitbox() end
    if Config.Resize.Enabled then task.wait(0.1); updateResize() end
    clearAllESP()
end)

----------------------------------------------------------------
-- CINEMATIC
----------------------------------------------------------------
local function tween(obj, t, props)
    return TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end
task.spawn(function()
    tween(darkOverlay, 0.6, { BackgroundTransparency=0.45 }):Play()
    for _,s in ipairs(shardList) do
        if not s.isText then
            task.spawn(function()
                if s.delay>0 then task.wait(s.delay) end
                s.frame.BackgroundTransparency=0
                TweenService:Create(s.frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { BackgroundTransparency=0.5 }):Play()
                local cur=s.frame.Position
                local tgt=UDim2.new(math.clamp(cur.X.Scale+s.driftOffset.X,0,1), 0, math.clamp(cur.Y.Scale+s.driftOffset.Y,0,1), 0)
                TweenService:Create(s.frame, TweenInfo.new(3.5, Enum.EasingStyle.Linear), { Position=tgt }):Play()
            end)
        end
    end
    task.wait(0.3)
    for _,s in ipairs(shardList) do
        if s.isText then
            task.spawn(function()
                if s.delay>0 then task.wait(s.delay) end
                s.frame.BackgroundTransparency=0
                TweenService:Create(s.frame, TweenInfo.new(1.6+math.random(-20,40)/100, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position=UDim2.new(0.5, s.targetOffset.X, 0.5, s.targetOffset.Y),
                    Rotation=math.random(0,360) }):Play()
            end)
        end
    end
    task.wait(1.6)
    tween(logoGlow, 0.5, { TextTransparency=0.55 }):Play()
    tween(logoText, 0.5, { TextTransparency=0 }):Play()
    task.wait(0.6)
    for _,s in ipairs(shardList) do
        if s.isText then TweenService:Create(s.frame, TweenInfo.new(0.5), { BackgroundTransparency=1 }):Play() end
    end
    task.wait(0.3)
    TweenService:Create(logoText, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { TextSize=86 }):Play()
    task.wait(0.2)
    tween(logoText, 0.3, { TextTransparency=1 }):Play()
    tween(logoGlow, 0.3, { TextTransparency=1 }):Play()
    tween(darkOverlay, 0.3, { BackgroundTransparency=1 }):Play()
    for _,s in ipairs(shardList) do
        if not s.isText then TweenService:Create(s.frame, TweenInfo.new(0.4), { BackgroundTransparency=1 }):Play() end
    end
    task.wait(0.4)
    darkOverlay:Destroy(); shardsContainer:Destroy(); logoText:Destroy(); logoGlow:Destroy()
    main.Visible=true
    main.BackgroundTransparency=Config.GUI.Transparency
    main.Size=UDim2.fromOffset(560,368)
    TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size=UDim2.fromOffset(700,460) }):Play()
    TweenService:Create(mStroke, TweenInfo.new(0.35), { Transparency=0.25 }):Play()
    playMenuOpen()
end)

updateFovCircle()
print("[FALID] v26.0 loaded. Menu: "..bindDisplayName(Config.GUI.ToggleBind))