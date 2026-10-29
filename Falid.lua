--// FALID (ANTI-KICK SAFE) — REAL INJECTOR EDITION v3.2 FINAL --//
-- Удалены: Portal Gun, вкладка "Другое", Invisible.
-- Панель настроек выезжает справа, не перекрывая вкладки.
-- Fly взят из FLYUI (BodyVelocity + BodyGyro).
-- Исправлен TP (показывает статус, если игроков нет).

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local RS            = game:GetService("RunService")
local GS            = game:GetService("GuiService")
local TS            = game:GetService("TweenService")
local SS            = game:GetService("SoundService")
local Debris        = game:GetService("Debris")
local Lighting      = game:GetService("Lighting")
local VIM           = game:GetService("VirtualInputManager")

local LP            = Players.LocalPlayer
local Cam           = workspace.CurrentCamera
local Mouse         = LP:GetMouse()

local _setclipboard = rawget(getfenv(), "setclipboard") or rawget(getfenv(), "toclipboard") or rawget(getfenv(), "Clipboard")

local function doClipboard(txt)
  if type(_setclipboard) == "function" then
    local ok = pcall(_setclipboard, txt); if ok then return true end
  end
  if type(setclipboard) == "function" then
    local ok = pcall(setclipboard, txt); if ok then return true end
  end
  return false
end

-- ============================================================
-- 1. CONFIG
-- ============================================================
local Cfg={
  Aim={Enabled=false,TargetPlayers=true,TargetBots=true,FOV=140,MaxDistance=2000,Smoothness=0.5,Bind=nil,AutoClick=true,ShowFOV=true,UseMouse=false},
  ESP={Enabled=false,ShowPlayers=true,ShowBots=true,MaxDistance=1500,Bind=nil,Color=Color3.fromRGB(70,140,255),
    Presets={{name="Красный",c=Color3.fromRGB(255,60,60)},{name="Оранжевый",c=Color3.fromRGB(255,150,40)},{name="Жёлтый",c=Color3.fromRGB(255,220,60)},{name="Зелёный",c=Color3.fromRGB(70,255,100)},{name="Голубой",c=Color3.fromRGB(70,220,255)},{name="Синий",c=Color3.fromRGB(70,140,255)},{name="Фиолетовый",c=Color3.fromRGB(180,80,255)},{name="Розовый",c=Color3.fromRGB(255,100,200)},{name="Белый",c=Color3.fromRGB(255,255,255)},{name="Чёрный",c=Color3.fromRGB(30,30,30)}}},
  Hitbox={Enabled=false,Size=8,ShowCube=true,Transparency=0.85,Color=Color3.fromRGB(180,80,255),TargetPlayers=true,MaxDistance=2000,Bind=nil},
  Fly={Enabled=false,Speed=60,Noclip=true,Bind=nil},
  ForceJump={Enabled=false,Power=100,Bind=nil},
  Speed={Enabled=false,Value=50,Bind=nil},
  Fullbright=false,
  AntiAFK=false,
  Death={Enabled=true,ShowText=true,ShowSound=true,SoundId="rbxassetid://5801257793",SoundVolume=3},
  Sounds={Enabled=true,MenuOpenId="rbxasset://sounds/electronicpingshort.wav",ToggleId="rbxasset://sounds/switch.wav",NotifyId="rbxasset://sounds/electronicpingshort.wav",Volume=0.6},
  World={TimeEnabled=false,ClockTime=14,FogEnabled=false,FogEnd=1000,BrightnessEnabled=false,Brightness=2,WeatherEnabled=false,WeatherType="Rain",WeatherAmount=60,WorldParticles=false,ParticleType="Sparkles"},
  GUI={ToggleBind=Enum.KeyCode.RightShift,Transparency=0.08,Scale=1,Accent=Color3.fromRGB(120,80,255),
    AccentPresets={{name="Фиолет",c=Color3.fromRGB(120,80,255)},{name="Синий",c=Color3.fromRGB(70,140,255)},{name="Голубой",c=Color3.fromRGB(70,220,255)},{name="Бирюза",c=Color3.fromRGB(60,240,200)},{name="Зелёный",c=Color3.fromRGB(70,220,120)},{name="Жёлтый",c=Color3.fromRGB(255,210,60)},{name="Оранж",c=Color3.fromRGB(255,140,40)},{name="Красный",c=Color3.fromRGB(255,60,60)},{name="Розовый",c=Color3.fromRGB(255,90,190)},{name="Белый",c=Color3.fromRGB(240,240,250)}}},
  Discord="https://discord.gg/5WnZJjTMfa"
}

local Fn={}
local UI={}
local Tabs={}
local Row={}
local St={
  Hitbox={saved={},conn=nil},
  ESP={hl={}},
  Speed={run=false,cn={}},
  FJ={run=false,cn={},saved=nil},
  W={wp={},wpart={}},
  FB={saved={}},
  AntiAFK={conn=nil,conn2=nil}
}

local flyState = {flying=false, bv=nil, bg=nil, loop=nil}

-- ============================================================
-- 2. GUI PARENT
-- ============================================================
local Gui=Instance.new("ScreenGui")
Gui.Name="Falid"; Gui.ResetOnSpawn=false; Gui.IgnoreGuiInset=true
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.DisplayOrder=999
Gui.Parent=LP:WaitForChild("PlayerGui")

-- ============================================================
-- 3. SOUNDS
-- ============================================================
local function playSnd(id,vol)
  if not Cfg.Sounds.Enabled then return end
  pcall(function()
    local s=Instance.new("Sound"); s.SoundId=id or Cfg.Sounds.ToggleId
    s.Volume=vol or Cfg.Sounds.Volume; s.Parent=SS; s:Play(); Debris:AddItem(s,4)
  end)
end
Fn.playMenu=function() playSnd(Cfg.Sounds.MenuOpenId) end
Fn.playToggle=function() playSnd(Cfg.Sounds.ToggleId) end
Fn.playNotify=function() playSnd(Cfg.Sounds.NotifyId) end

-- ============================================================
-- 4. BIND HELPERS
-- ============================================================
local function bindName(b)
  if not b then return "None" end
  local n=b.Name
  if n=="MouseButton1" then return "ЛКМ"
  elseif n=="MouseButton2" then return "ПКМ"
  elseif n=="MouseButton3" then return "СКМ" end
  return n
end
local function isMouseBind(i)
  local n=i.UserInputType.Name
  return n=="MouseButton1" or n=="MouseButton2" or n=="MouseButton3"
end

-- ============================================================
-- 5. TOAST
-- ============================================================
UI.tc=Instance.new("Frame")
UI.tc.Size=UDim2.fromScale(1,1); UI.tc.BackgroundTransparency=1
UI.tc.ZIndex=500; UI.tc.Parent=Gui

Fn.showToast=function(text,color)
  color=color or Cfg.GUI.Accent
  Fn.playNotify()
  local t=Instance.new("TextButton")
  t.Size=UDim2.fromOffset(280,44); t.AnchorPoint=Vector2.new(0.5,0)
  t.Position=UDim2.new(0.5,0,0,-60); t.BackgroundColor3=Color3.fromRGB(24,24,32)
  t.Text=""; t.AutoButtonColor=false; t.ZIndex=501; t.Parent=UI.tc
  Instance.new("UICorner",t).CornerRadius=UDim.new(0,10)
  local st=Instance.new("UIStroke"); st.Color=color; st.Thickness=1.5; st.Transparency=0.2; st.Parent=t
  local ic=Instance.new("Frame"); ic.Size=UDim2.fromOffset(24,24)
  ic.Position=UDim2.new(0,10,0.5,-12); ic.BackgroundColor3=color
  ic.BorderSizePixel=0; ic.ZIndex=502; ic.Parent=t
  Instance.new("UICorner",ic).CornerRadius=UDim.new(1,0)
  local ck=Instance.new("TextLabel"); ck.Size=UDim2.fromScale(1,1)
  ck.BackgroundTransparency=1; ck.Text="✓"; ck.Font=Enum.Font.GothamBold
  ck.TextSize=16; ck.TextColor3=Color3.fromRGB(255,255,255); ck.ZIndex=503; ck.Parent=ic
  local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-48,1,0)
  lb.Position=UDim2.new(0,42,0,0); lb.BackgroundTransparency=1; lb.Text=text
  lb.Font=Enum.Font.GothamSemibold; lb.TextSize=13
  lb.TextColor3=Color3.fromRGB(240,240,250); lb.TextXAlignment=Enum.TextXAlignment.Left
  lb.ZIndex=502; lb.Parent=t
  TS:Create(t,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Position=UDim2.new(0.5,0,0,24)}):Play()
  task.delay(2.2,function()
    local tw=TS:Create(t,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
      {Position=UDim2.new(0.5,0,0,-60),BackgroundTransparency=1})
    tw:Play()
    TS:Create(st,TweenInfo.new(0.3),{Transparency=1}):Play()
    TS:Create(lb,TweenInfo.new(0.3),{TextTransparency=1}):Play()
    TS:Create(ck,TweenInfo.new(0.3),{TextTransparency=1}):Play()
    TS:Create(ic,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
    tw.Completed:Connect(function() t:Destroy() end)
  end)
end

-- ============================================================
-- 6. DEATH EFFECT
-- ============================================================
local D={}
D.gui=Instance.new("ScreenGui"); D.gui.Name="Falid_Death"; D.gui.ResetOnSpawn=false
D.gui.IgnoreGuiInset=true; D.gui.DisplayOrder=997; D.gui.Parent=LP:WaitForChild("PlayerGui")
D.ov=Instance.new("Frame"); D.ov.Size=UDim2.fromScale(1,1)
D.ov.BackgroundColor3=Color3.fromRGB(200,0,0); D.ov.BackgroundTransparency=1
D.ov.BorderSizePixel=0; D.ov.Visible=false; D.ov.ZIndex=900; D.ov.Parent=D.gui
D.vg=Instance.new("Frame"); D.vg.Size=UDim2.fromScale(1,1)
D.vg.BackgroundColor3=Color3.fromRGB(0,0,0); D.vg.BackgroundTransparency=1
D.vg.BorderSizePixel=0; D.vg.Visible=false; D.vg.ZIndex=901; D.vg.Parent=D.gui
D.tx=Instance.new("TextLabel"); D.tx.Size=UDim2.fromScale(1,1); D.tx.BackgroundTransparency=1
D.tx.Text="ТЫ УМЕР"; D.tx.Font=Enum.Font.GothamBlack; D.tx.TextSize=110
D.tx.TextColor3=Color3.fromRGB(255,255,255); D.tx.TextTransparency=1; D.tx.TextStrokeTransparency=1
D.tx.TextStrokeColor3=Color3.fromRGB(200,0,0); D.tx.ZIndex=902; D.tx.Parent=D.gui
D.sb=Instance.new("TextLabel"); D.sb.Size=UDim2.new(1,0,0,40)
D.sb.Position=UDim2.new(0.5,0,0.5,90); D.sb.AnchorPoint=Vector2.new(0.5,0)
D.sb.BackgroundTransparency=1; D.sb.Text="FALID"; D.sb.Font=Enum.Font.GothamBold
D.sb.TextSize=22; D.sb.TextColor3=Cfg.GUI.Accent; D.sb.TextTransparency=1
D.sb.ZIndex=902; D.sb.Parent=D.gui
D.active=false

local function playDeathSnd()
  if not Cfg.Death.ShowSound then return end
  local id,vol=Cfg.Death.SoundId,Cfg.Death.SoundVolume
  pcall(function() local s=Instance.new("Sound"); s.SoundId=id; s.Volume=vol; s.PlayOnRemove=true; s.Parent=workspace; s:Destroy() end)
  pcall(function() local s=Instance.new("Sound"); s.SoundId=id; s.Volume=vol; s.Parent=SS; s:Play(); Debris:AddItem(s,8) end)
end
Fn.deathSnd=playDeathSnd

Fn.triggerDeath=function()
  if D.active or not Cfg.Death.Enabled then return end
  D.active=true; playDeathSnd()
  if Cfg.Death.ShowText then
    D.ov.Visible=true; D.vg.Visible=true
    TS:Create(D.ov,TweenInfo.new(0.15),{BackgroundTransparency=0.55}):Play()
    TS:Create(D.vg,TweenInfo.new(0.4),{BackgroundTransparency=0.2}):Play()
    D.tx.TextTransparency=1; D.tx.TextStrokeTransparency=1; D.tx.TextSize=60; D.sb.TextTransparency=1
    TS:Create(D.tx,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
      {TextTransparency=0,TextStrokeTransparency=0.3,TextSize=120}):Play()
    TS:Create(D.sb,TweenInfo.new(0.45),{TextTransparency=0.2}):Play()
    task.delay(2.0,function()
      TS:Create(D.ov,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
      TS:Create(D.vg,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
      TS:Create(D.tx,TweenInfo.new(0.5),{TextTransparency=1,TextStrokeTransparency=1}):Play()
      TS:Create(D.sb,TweenInfo.new(0.5),{TextTransparency=1}):Play()
      task.wait(0.6); D.ov.Visible=false; D.vg.Visible=false; D.active=false
    end)
  else D.active=false end
end
local function hookDeath(ch)
  if not ch then return end
  local h=ch:WaitForChild("Humanoid",5); if not h then return end
  h.Died:Connect(function() task.wait(0.15); Fn.triggerDeath() end)
end
if LP.Character then hookDeath(LP.Character) end
LP.CharacterAdded:Connect(hookDeath)

-- ============================================================
-- 7. FOV
-- ============================================================
local Fv={}
Fv.gui=Instance.new("ScreenGui"); Fv.gui.Name="Falid_FOV"; Fv.gui.ResetOnSpawn=false
Fv.gui.IgnoreGuiInset=true; Fv.gui.DisplayOrder=998; Fv.gui.Parent=LP:WaitForChild("PlayerGui")
Fv.c=Instance.new("Frame"); Fv.c.AnchorPoint=Vector2.new(0.5,0.5)
Fv.c.Position=UDim2.fromScale(0.5,0.5); Fv.c.BackgroundTransparency=1
Fv.c.Visible=false; Fv.c.Parent=Fv.gui
Instance.new("UICorner",Fv.c).CornerRadius=UDim.new(1,0)
Fv.s=Instance.new("UIStroke"); Fv.s.Thickness=1.5; Fv.s.Color=Cfg.GUI.Accent
Fv.s.Transparency=0.25; Fv.s.Parent=Fv.c
Fn.updFov=function()
  Fv.c.Size=UDim2.fromOffset(Cfg.Aim.FOV*2,Cfg.Aim.FOV*2)
  Fv.c.Visible=Cfg.Aim.Enabled and Cfg.Aim.ShowFOV
end
Fn.isMenuOpen=function() return GS:IsMenuOpen() end

-- ============================================================
-- 8. LOADER
-- ============================================================
local Ld={}
Ld.dark=Instance.new("Frame"); Ld.dark.Size=UDim2.fromScale(1,1)
Ld.dark.BackgroundColor3=Color3.fromRGB(0,0,0); Ld.dark.BackgroundTransparency=1
Ld.dark.BorderSizePixel=0; Ld.dark.ZIndex=200; Ld.dark.Parent=Gui
Ld.shards=Instance.new("Frame"); Ld.shards.Size=UDim2.fromScale(1,1)
Ld.shards.BackgroundTransparency=1; Ld.shards.ZIndex=201; Ld.shards.Parent=Gui
Ld.txt=Instance.new("TextLabel"); Ld.txt.BackgroundTransparency=1; Ld.txt.Text="F A L I D"
Ld.txt.Font=Enum.Font.GothamBlack; Ld.txt.TextSize=78
Ld.txt.TextColor3=Color3.fromRGB(245,245,255); Ld.txt.TextTransparency=1
Ld.txt.Size=UDim2.fromOffset(600,120); Ld.txt.AnchorPoint=Vector2.new(0.5,0.5)
Ld.txt.Position=UDim2.fromScale(0.5,0.5); Ld.txt.ZIndex=203; Ld.txt.Parent=Gui
Ld.glow=Instance.new("TextLabel"); Ld.glow.BackgroundTransparency=1; Ld.glow.Text="F A L I D"
Ld.glow.Font=Enum.Font.GothamBlack; Ld.glow.TextSize=78
Ld.glow.TextColor3=Cfg.GUI.Accent; Ld.glow.TextTransparency=1
Ld.glow.Size=UDim2.fromOffset(600,120); Ld.glow.AnchorPoint=Vector2.new(0.5,0.5)
Ld.glow.Position=UDim2.fromScale(0.5,0.5); Ld.glow.ZIndex=202; Ld.glow.Parent=Gui

Ld.list={}
do
  local SC=900; local ST=450
  for i=1,SC do
    local isT=i<=ST
    local sz=math.random(3,8)
    local sh=Instance.new("Frame")
    sh.Size=UDim2.fromOffset(sz,sz); sh.AnchorPoint=Vector2.new(0.5,0.5)
    sh.BackgroundColor3=Color3.fromRGB(math.random(230,255),math.random(80,140),math.random(170,220))
    sh.BorderSizePixel=0; sh.Rotation=math.random(0,360); sh.ZIndex=201; sh.BackgroundTransparency=1
    local sx=math.random(-10,110)/100; local sy=math.random(-10,110)/100
    local to=isT and Vector2.new(math.random(-300,300),math.random(-200,200)) or nil
    sh.Position=UDim2.fromScale(sx,sy)
    if sz>=6 then Instance.new("UICorner",sh).CornerRadius=UDim.new(1,0)
    else Instance.new("UICorner",sh).CornerRadius=UDim.new(0,1) end
    sh.Parent=Ld.shards
    Ld.list[i]={f=sh,isT=isT,to=to,d=math.random(0,isT and 8 or 15)/100,
      dr=isT and Vector2.new(0,0) or Vector2.new((math.random()-0.5)*0.2,(math.random()-0.5)*0.2)}
  end
end

-- ============================================================
-- 9. MAIN FRAME
-- ============================================================
UI.main=Instance.new("Frame"); UI.main.Size=UDim2.fromOffset(700,460)
UI.main.AnchorPoint=Vector2.new(0.5,0.5); UI.main.Position=UDim2.fromScale(0.5,0.5)
UI.main.BackgroundColor3=Color3.fromRGB(16,16,22); UI.main.BackgroundTransparency=1
UI.main.BorderSizePixel=0; UI.main.Visible=false; UI.main.Parent=Gui
Instance.new("UICorner",UI.main).CornerRadius=UDim.new(0,14)
UI.scale=Instance.new("UIScale"); UI.scale.Scale=Cfg.GUI.Scale; UI.scale.Parent=UI.main
UI.stroke=Instance.new("UIStroke"); UI.stroke.Color=Cfg.GUI.Accent
UI.stroke.Thickness=1.5; UI.stroke.Transparency=1; UI.stroke.Parent=UI.main

UI.drag={a=false,s=nil,p=nil}
UI.main.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
    UI.drag.a=true; UI.drag.s=i.Position; UI.drag.p=UI.main.Position
  end
end)
UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then UI.drag.a=false end
end)
UIS.InputChanged:Connect(function(i)
  if UI.drag.a and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
    local d=i.Position-UI.drag.s
    UI.main.Position=UDim2.new(UI.drag.p.X.Scale,UI.drag.p.X.Offset+d.X,UI.drag.p.Y.Scale,UI.drag.p.Y.Offset+d.Y)
  end
end)

UI.title=Instance.new("TextLabel"); UI.title.BackgroundTransparency=1
UI.title.Size=UDim2.new(1,-30,0,40); UI.title.Position=UDim2.fromOffset(20,8)
UI.title.Font=Enum.Font.GothamBold; UI.title.Text="FALID"; UI.title.TextSize=24
UI.title.TextColor3=Color3.fromRGB(245,245,255)
UI.title.TextXAlignment=Enum.TextXAlignment.Left; UI.title.Parent=UI.main

UI.sub=Instance.new("TextLabel"); UI.sub.BackgroundTransparency=1
UI.sub.Size=UDim2.new(1,-30,0,16); UI.sub.Position=UDim2.fromOffset(22,42)
UI.sub.Font=Enum.Font.Gotham; UI.sub.Text="Rick & Morty"
UI.sub.TextSize=11; UI.sub.TextColor3=Color3.fromRGB(145,145,160)
UI.sub.TextXAlignment=Enum.TextXAlignment.Left; UI.sub.Parent=UI.main

UI.dis=Instance.new("TextButton"); UI.dis.Size=UDim2.fromOffset(36,36)
UI.dis.Position=UDim2.new(1,-95,0,14); UI.dis.BackgroundColor3=Color3.fromRGB(30,30,40)
UI.dis.Text=""; UI.dis.AutoButtonColor=false; UI.dis.Parent=UI.main
Instance.new("UICorner",UI.dis).CornerRadius=UDim.new(0,8)
do
  local di=Instance.new("Frame"); di.Size=UDim2.fromOffset(20,14)
  di.AnchorPoint=Vector2.new(0.5,0.5); di.Position=UDim2.fromScale(0.5,0.5)
  di.BackgroundColor3=Color3.fromRGB(120,80,255); di.BorderSizePixel=0; di.Parent=UI.dis
  Instance.new("UICorner",di).CornerRadius=UDim.new(0,4)
  for _,x in ipairs({-6,3}) do
    local e=Instance.new("Frame"); e.Size=UDim2.fromOffset(3,3)
    e.Position=UDim2.new(0.5,x,0.5,-2); e.BackgroundColor3=Color3.fromRGB(255,255,255)
    e.BorderSizePixel=0; e.Parent=di
    Instance.new("UICorner",e).CornerRadius=UDim.new(1,0)
  end
end
UI.dis.MouseButton1Click:Connect(function()
  if doClipboard(Cfg.Discord) then Fn.showToast("Discord скопирован!",Color3.fromRGB(120,80,255))
  else Fn.showToast("Скопируй: "..Cfg.Discord,Color3.fromRGB(255,60,60)) end
end)

UI.gear=Instance.new("TextButton"); UI.gear.Size=UDim2.fromOffset(36,36)
UI.gear.Position=UDim2.new(1,-50,0,14); UI.gear.BackgroundColor3=Color3.fromRGB(30,30,40)
UI.gear.Text="⚙"; UI.gear.Font=Enum.Font.GothamBold; UI.gear.TextSize=20
UI.gear.TextColor3=Color3.fromRGB(200,200,215); UI.gear.AutoButtonColor=false
UI.gear.Parent=UI.main
Instance.new("UICorner",UI.gear).CornerRadius=UDim.new(0,8)

UI.tabBar=Instance.new("Frame"); UI.tabBar.BackgroundTransparency=1
UI.tabBar.Position=UDim2.fromOffset(20,68); UI.tabBar.Size=UDim2.new(1,-40,0,32)
UI.tabBar.Parent=UI.main
do
  local tl=Instance.new("UIListLayout"); tl.FillDirection=Enum.FillDirection.Horizontal
  tl.Padding=UDim.new(0,6); tl.Parent=UI.tabBar
end

UI.cont=Instance.new("ScrollingFrame"); UI.cont.BackgroundTransparency=1
UI.cont.BorderSizePixel=0; UI.cont.Position=UDim2.fromOffset(20,108)
UI.cont.Size=UDim2.new(1,-40,1,-128); UI.cont.CanvasSize=UDim2.new(0,0,0,0)
UI.cont.ScrollBarThickness=6; UI.cont.ScrollBarImageColor3=Cfg.GUI.Accent
UI.cont.ScrollingDirection=Enum.ScrollingDirection.Y
UI.cont.ElasticBehavior=Enum.ElasticBehavior.Never; UI.cont.Parent=UI.main
pcall(function() UI.cont.AutomaticCanvasSize=Enum.AutomaticSize.Y end)

Fn.switchTab=function(n)
  for k,v in pairs(Tabs) do
    local a=(k==n)
    v.btn.BackgroundColor3=a and Cfg.GUI.Accent or Color3.fromRGB(30,30,40)
    v.btn.TextColor3=a and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,215)
    v.cont.Visible=a
  end
  if n=="tp" and Fn.refreshTP then
    task.defer(function() Fn.refreshTP(true) end)
  end
end
local function createTab(n,d,w,skip)
  local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(w or 90,32)
  b.BackgroundColor3=Color3.fromRGB(30,30,40); b.Text=d
  b.Font=Enum.Font.GothamSemibold; b.TextSize=13
  b.TextColor3=Color3.fromRGB(200,200,215); b.AutoButtonColor=false; b.Parent=UI.tabBar
  Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
  local c=Instance.new("Frame"); c.BackgroundTransparency=1
  c.Size=UDim2.new(1,0,0,0); c.AutomaticSize=Enum.AutomaticSize.Y
  c.Visible=false; c.Parent=UI.cont
  if not skip then
    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,10)
    l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=c
  end
  b.MouseButton1Click:Connect(function() Fn.switchTab(n) end)
  Tabs[n]={btn=b,cont=c}
  return c
end

Row.main=createTab("main","Main",70)
Row.tp=createTab("tp","TP",70,true)
Row.world=createTab("world","World",80)
Row.misc=createTab("misc","Misc",70)

local function createRow(parent,name,desc)
  local r=Instance.new("Frame"); r.Size=UDim2.new(1,0,0,62)
  r.BackgroundColor3=Color3.fromRGB(25,25,33); r.BorderSizePixel=0; r.Parent=parent
  Instance.new("UICorner",r).CornerRadius=UDim.new(0,10)
  local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
  l.Position=UDim2.fromOffset(15,7); l.Size=UDim2.new(1,-130,0,23)
  l.Font=Enum.Font.GothamSemibold; l.Text=name; l.TextSize=15
  l.TextColor3=Color3.fromRGB(235,235,245); l.TextXAlignment=Enum.TextXAlignment.Left
  l.Parent=r
  local d=Instance.new("TextLabel"); d.BackgroundTransparency=1
  d.Position=UDim2.fromOffset(15,30); d.Size=UDim2.new(1,-130,0,20)
  d.Font=Enum.Font.Gotham; d.Text=desc; d.TextSize=11
  d.TextColor3=Color3.fromRGB(135,135,150); d.TextXAlignment=Enum.TextXAlignment.Left
  d.Parent=r
  return r
end
local function createToggle(parent,default,cb)
  local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(65,30)
  b.Position=UDim2.new(1,-105,0.5,-15); b.BackgroundColor3=Color3.fromRGB(45,45,55)
  b.Text=""; b.AutoButtonColor=false; b.Parent=parent
  Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
  local s=default
  local function upd()
    b.BackgroundColor3=s and Cfg.GUI.Accent or Color3.fromRGB(45,45,55)
    cb(s)
  end
  b.MouseButton1Click:Connect(function() s=not s; Fn.playToggle(); upd() end)
  upd()
  return function(v) s=v; upd() end
end
local function createGear(parent,cb)
  local g=Instance.new("TextButton"); g.Size=UDim2.fromOffset(32,32)
  g.Position=UDim2.new(1,-40,0.5,-16); g.BackgroundTransparency=1; g.Text="⚙"
  g.Font=Enum.Font.GothamBold; g.TextSize=20; g.TextColor3=Color3.fromRGB(170,170,185)
  g.Parent=parent; g.MouseButton1Click:Connect(function() Fn.playToggle(); cb() end)
  return g
end

-- ============================================================
-- 10. SETTINGS PANEL (выезжает справа, не перекрывает вкладки)
-- ============================================================
UI.panel=Instance.new("Frame"); UI.panel.Size=UDim2.fromOffset(260,420)
UI.panel.AnchorPoint=Vector2.new(1, 0)
-- Позиция справа от основного окна
UI.panel.Position=UDim2.new(1, 15, 0, 0) 
UI.panel.BackgroundColor3=Color3.fromRGB(20,20,28)
UI.panel.BorderSizePixel=0; UI.panel.Visible=false
UI.panel.ZIndex=10; UI.panel.Parent=UI.main
Instance.new("UICorner",UI.panel).CornerRadius=UDim.new(0,12)
UI.ps=Instance.new("UIStroke"); UI.ps.Color=Cfg.GUI.Accent
UI.ps.Transparency=0.3; UI.ps.Parent=UI.panel
UI.pt=Instance.new("TextLabel"); UI.pt.BackgroundTransparency=1
UI.pt.Size=UDim2.new(1,-20,0,40); UI.pt.Position=UDim2.fromOffset(10,5)
UI.pt.Font=Enum.Font.GothamBold; UI.pt.Text="Настройки"; UI.pt.TextSize=18
UI.pt.TextColor3=Color3.fromRGB(240,240,250); UI.pt.TextXAlignment=Enum.TextXAlignment.Left
UI.pt.Parent=UI.panel
UI.pc=Instance.new("ScrollingFrame"); UI.pc.BackgroundTransparency=1
UI.pc.BorderSizePixel=0; UI.pc.Position=UDim2.fromOffset(10,50)
UI.pc.Size=UDim2.new(1,-20,1,-60); UI.pc.CanvasSize=UDim2.new(0,0,0,0)
UI.pc.ScrollBarThickness=6; UI.pc.ScrollBarImageColor3=Cfg.GUI.Accent
UI.pc.ScrollingDirection=Enum.ScrollingDirection.Y; UI.pc.Active=true
UI.pc.ElasticBehavior=Enum.ElasticBehavior.Never; UI.pc.Parent=UI.panel
pcall(function() UI.pc.AutomaticCanvasSize=Enum.AutomaticSize.Y end)
do
  local pl=Instance.new("UIListLayout"); pl.Padding=UDim.new(0,8); pl.Parent=UI.pc
end

local function clrP()
  for _,v in ipairs(UI.pc:GetChildren()) do if v:IsA("GuiObject") then v:Destroy() end end
  UI.pc.CanvasPosition=Vector2.new(0,0)
end
Fn.clrP=clrP

Fn.closePanel = function()
  UI.panel.Visible = false
  UI.pt.Text = "Меню"
  if not UI.main.Visible then
    UI.main.Visible = true
    UI.main.BackgroundTransparency = Cfg.GUI.Transparency
    UI.stroke.Transparency = 0.25
  end
end

-- Закрытие панели по клику вне неё
UI.main.InputBegan:Connect(function(i)
  if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
    if UI.panel.Visible then
      local mp = i.Position
      local pp = UI.panel.AbsolutePosition
      local ps = UI.panel.AbsoluteSize
      local gp = UI.gear.AbsolutePosition
      local gs = UI.gear.AbsoluteSize
      
      local inPanel = mp.X >= pp.X and mp.X <= pp.X + ps.X and mp.Y >= pp.Y and mp.Y <= pp.Y + ps.Y
      local inGear = mp.X >= gp.X and mp.X <= gp.X + gs.X and mp.Y >= gp.Y and mp.Y <= gp.Y + gs.Y
      
      if not inPanel and not inGear then
        Fn.closePanel()
      end
    end
  end
end)

local function sLbl(t)
  local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
  l.Size=UDim2.new(1,0,0,28); l.Font=Enum.Font.GothamSemibold; l.Text=t
  l.TextSize=12; l.TextColor3=Color3.fromRGB(200,200,215)
  l.TextWrapped=true; l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=UI.pc
end
local function sBtn(t,cb)
  local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,34)
  b.BackgroundColor3=Color3.fromRGB(34,34,44); b.Text=t; b.Font=Enum.Font.Gotham
  b.TextSize=11; b.TextColor3=Color3.fromRGB(220,220,230); b.TextWrapped=true
  b.Parent=UI.pc
  Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
  b.MouseButton1Click:Connect(function() Fn.playToggle(); cb() end)
  return b
end
local function sSw(lb,getC,oP,oN)
  local r=Instance.new("Frame"); r.Size=UDim2.new(1,0,0,34)
  r.BackgroundColor3=Color3.fromRGB(34,34,44); r.BorderSizePixel=0; r.Parent=UI.pc
  Instance.new("UICorner",r).CornerRadius=UDim.new(0,7)
  local n=Instance.new("TextLabel"); n.BackgroundTransparency=1
  n.Position=UDim2.fromOffset(10,0); n.Size=UDim2.new(1,-100,1,0)
  n.Font=Enum.Font.Gotham; n.Text=lb; n.TextSize=11
  n.TextColor3=Color3.fromRGB(220,220,230); n.TextXAlignment=Enum.TextXAlignment.Left; n.Parent=r
  local sw=Instance.new("Frame"); sw.Size=UDim2.fromOffset(28,22)
  sw.Position=UDim2.new(1,-100,0.5,-11); sw.BackgroundColor3=getC()
  sw.BorderSizePixel=0; sw.Parent=r
  Instance.new("UICorner",sw).CornerRadius=UDim.new(0,5)
  local pv=Instance.new("TextButton"); pv.Size=UDim2.fromOffset(22,22)
  pv.Position=UDim2.new(1,-70,0.5,-11); pv.BackgroundColor3=Color3.fromRGB(48,48,60)
  pv.Text="◀"; pv.Font=Enum.Font.GothamBold; pv.TextSize=12
  pv.TextColor3=Color3.fromRGB(220,220,230); pv.Parent=r
  Instance.new("UICorner",pv).CornerRadius=UDim.new(0,5)
  local nx=Instance.new("TextButton"); nx.Size=UDim2.fromOffset(22,22)
  nx.Position=UDim2.new(1,-44,0.5,-11); nx.BackgroundColor3=Color3.fromRGB(48,48,60)
  nx.Text="▶"; nx.Font=Enum.Font.GothamBold; nx.TextSize=12
  nx.TextColor3=Color3.fromRGB(220,220,230); nx.Parent=r
  Instance.new("UICorner",nx).CornerRadius=UDim.new(0,5)
  pv.MouseButton1Click:Connect(function() Fn.playToggle(); oP(); sw.BackgroundColor3=getC() end)
  nx.MouseButton1Click:Connect(function() Fn.playToggle(); oN(); sw.BackgroundColor3=getC() end)
end
local function sSld(mn,mx,iv,cb)
  local h=Instance.new("Frame"); h.Size=UDim2.new(1,0,0,42)
  h.BackgroundColor3=Color3.fromRGB(34,34,44); h.BorderSizePixel=0; h.Parent=UI.pc
  Instance.new("UICorner",h).CornerRadius=UDim.new(0,7)
  local vl=Instance.new("TextLabel"); vl.BackgroundTransparency=1
  vl.Size=UDim2.new(1,-20,0,16); vl.Position=UDim2.fromOffset(10,3)
  vl.Font=Enum.Font.Gotham; vl.Text=tostring(math.floor(iv*100)/100)
  vl.TextSize=11; vl.TextColor3=Color3.fromRGB(200,200,215)
  vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=h
  local b=Instance.new("Frame"); b.Size=UDim2.new(1,-20,0,8)
  b.Position=UDim2.new(0,10,1,-16); b.BackgroundColor3=Color3.fromRGB(55,55,70)
  b.BorderSizePixel=0; b.Parent=h
  Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
  local fl=Instance.new("Frame"); fl.Size=UDim2.new((iv-mn)/(mx-mn),0,1,0)
  fl.BackgroundColor3=Cfg.GUI.Accent; fl.BorderSizePixel=0; fl.Parent=b
  Instance.new("UICorner",fl).CornerRadius=UDim.new(1,0)
  local kn=Instance.new("Frame"); kn.Size=UDim2.fromOffset(14,14)
  kn.AnchorPoint=Vector2.new(0.5,0.5); kn.Position=UDim2.new((iv-mn)/(mx-mn),0,0.5,0)
  kn.BackgroundColor3=Color3.fromRGB(240,240,250); kn.BorderSizePixel=0; kn.Parent=b
  Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
  local dr=false
  local function setX(x)
    local rel=math.clamp((x-b.AbsolutePosition.X)/b.AbsoluteSize.X,0,1)
    local v=math.floor((mn+rel*(mx-mn))*100)/100
    fl.Size=UDim2.new(rel,0,1,0); kn.Position=UDim2.new(rel,0,0.5,0)
    vl.Text=tostring(v); cb(v)
  end
  b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true; setX(i.Position.X) end end)
  kn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true end end)
  UIS.InputChanged:Connect(function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setX(i.Position.X) end end)
  UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
end

local function findIdx(c,prs)
  local b,bd=1,math.huge
  for i,p in ipairs(prs) do
    local d=(p.c.R-c.R)^2+(p.c.G-c.G)^2+(p.c.B-c.B)^2
    if d<bd then bd=d; b=i end
  end
  return b
end
local function cycPre(c,d)
  local i=findIdx(c,Cfg.ESP.Presets)+d; local n=#Cfg.ESP.Presets
  if i<1 then i=n end; if i>n then i=1 end
  return Cfg.ESP.Presets[i].c
end
local function cycAcc(c,d)
  local i=findIdx(c,Cfg.GUI.AccentPresets)+d; local n=#Cfg.GUI.AccentPresets
  if i<1 then i=n end; if i>n then i=1 end
  return Cfg.GUI.AccentPresets[i].c
end
Fn.cycPre=cycPre; Fn.cycAcc=cycAcc; Fn.findIdx=findIdx

Fn.listenKey=function(title,restore,onK,onF)
  title.Text="Нажми клавишу... (Esc отмена)"
  task.wait(0.15)
  local cn
  cn=UIS.InputBegan:Connect(function(i,gp)
    local im=isMouseBind(i); if gp and not im then return end
    local b=nil
    if i.UserInputType==Enum.UserInputType.Keyboard then
      if i.KeyCode==Enum.KeyCode.Unknown then return end
      if i.KeyCode==Enum.KeyCode.Escape then cn:Disconnect(); title.Text=restore; if onF then onF() end; return end
      b=i.KeyCode
    elseif im then b=i.UserInputType end
    if b then
      onK(b); cn:Disconnect(); title.Text=restore
      if Fn.refreshBinds then Fn.refreshBinds() end
      if onF then onF() end
    end
  end)
end

Fn.getRoot=function(m)
  return m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("UpperTorso")
      or m:FindFirstChild("Torso") or m:FindFirstChild("Head")
end
Fn.getHead=function(m)
  return m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
      or m:FindFirstChild("UpperTorso") or m:FindFirstChild("Torso")
end

-- ============================================================
-- 11. BOT HELPERS
-- ============================================================
local function isBotModel(m)
  if not m or not m:IsA("Model") then return false end
  if m==LP.Character then return false end
  local h=m:FindFirstChildOfClass("Humanoid")
  if not h or h.Health<=0 then return false end
  local pl=Players:GetPlayerFromCharacter(m)
  if pl then return false end
  return true
end
local function getBots()
  local t={}
  for _,m in ipairs(workspace:GetChildren()) do
    if isBotModel(m) then table.insert(t,m) end
  end
  return t
end

-- ============================================================
-- 12. GLOBAL SETTINGS PAGE
-- ============================================================
local function pgGlobal()
  clrP(); UI.pt.Text="Меню"; UI.panel.Visible=true
  sLbl("Прозрачность меню: "..string.format("%.2f",Cfg.GUI.Transparency))
  sBtn("Сделать прозрачнее (+0.05)",function()
    Cfg.GUI.Transparency=math.min(0.9,Cfg.GUI.Transparency+0.05)
    if UI.main.Visible then UI.main.BackgroundTransparency=Cfg.GUI.Transparency end
    pgGlobal()
  end)
  sBtn("Сделать плотнее (−0.05)",function()
    Cfg.GUI.Transparency=math.max(0,Cfg.GUI.Transparency-0.05)
    if UI.main.Visible then UI.main.BackgroundTransparency=Cfg.GUI.Transparency end
    pgGlobal()
  end)
  sLbl("Масштаб меню: "..string.format("%.2f",Cfg.GUI.Scale))
  sBtn("Увеличить (+0.05)",function()
    Cfg.GUI.Scale=math.min(1.5,Cfg.GUI.Scale+0.05); UI.scale.Scale=Cfg.GUI.Scale; pgGlobal()
  end)
  sBtn("Уменьшить (−0.05)",function()
    Cfg.GUI.Scale=math.max(0.5,Cfg.GUI.Scale-0.05); UI.scale.Scale=Cfg.GUI.Scale; pgGlobal()
  end)
  sBtn("Сбросить масштаб (1.0)",function() Cfg.GUI.Scale=1; UI.scale.Scale=1; pgGlobal() end)
  sLbl("Цвет акцента")
  sSw("тема: "..Cfg.GUI.AccentPresets[findIdx(Cfg.GUI.Accent,Cfg.GUI.AccentPresets)].name,
    function() return Cfg.GUI.Accent end,
    function() Cfg.GUI.Accent=cycAcc(Cfg.GUI.Accent,-1); Fn.applyAccent() end,
    function() Cfg.GUI.Accent=cycAcc(Cfg.GUI.Accent,1); Fn.applyAccent() end)
  sLbl("Клавиша открытия меню")
  sBtn("Сейчас: "..bindName(Cfg.GUI.ToggleBind).." — нажми, чтобы сменить",
    function() Fn.listenKey(UI.pt,"Меню",function(k) Cfg.GUI.ToggleBind=k end,pgGlobal) end)
  sLbl("Звуки интерфейса")
  sBtn("Звуки: "..(Cfg.Sounds.Enabled and "ВКЛ" or "ВЫКЛ"),
    function() Cfg.Sounds.Enabled=not Cfg.Sounds.Enabled; pgGlobal() end)
  sBtn("Громкость: "..string.format("%.1f",Cfg.Sounds.Volume).." — +0.2",
    function() Cfg.Sounds.Volume=math.min(2,Cfg.Sounds.Volume+0.2); pgGlobal() end)
  sBtn("Проверить звук меню",function() Fn.playMenu() end)
  sBtn("Проверить звук переключателя",function() Fn.playToggle() end)
  sLbl("Эффект при смерти")
  sBtn("Эффект: "..(Cfg.Death.Enabled and "ВКЛ" or "ВЫКЛ"),
    function() Cfg.Death.Enabled=not Cfg.Death.Enabled; pgGlobal() end)
  sBtn("Звук смерти: "..(Cfg.Death.ShowSound and "ВКЛ" or "ВЫКЛ"),
    function() Cfg.Death.ShowSound=not Cfg.Death.ShowSound; pgGlobal() end)
  sBtn("Проверить звук смерти",function() playDeathSnd() end)
  sBtn("Проверить эффект смерти",function() D.active=false; Fn.triggerDeath() end)
end
Fn.pgGlobal = pgGlobal

UI.gear.MouseButton1Click:Connect(function()
  if UI.panel.Visible then
    Fn.closePanel()
  else
    pgGlobal()
  end
end)

Fn.applyAccent=function()
  UI.stroke.Color=Cfg.GUI.Accent; UI.ps.Color=Cfg.GUI.Accent; Fv.s.Color=Cfg.GUI.Accent
  UI.cont.ScrollBarImageColor3=Cfg.GUI.Accent; UI.pc.ScrollBarImageColor3=Cfg.GUI.Accent
  Ld.glow.TextColor3=Cfg.GUI.Accent; D.sb.TextColor3=Cfg.GUI.Accent
  for _,tb in pairs(Tabs) do if tb.cont.Visible then tb.btn.BackgroundColor3=Cfg.GUI.Accent end end
end

-- ============================================================
-- 13. AIM PAGE
-- ============================================================
local function pgAim()
  clrP(); UI.pt.Text="Aim"; UI.panel.Visible=true
  sLbl("Цели")
  sBtn("Игроки: "..(Cfg.Aim.TargetPlayers and "ВКЛ" or "ВЫКЛ"),function() Cfg.Aim.TargetPlayers=not Cfg.Aim.TargetPlayers; pgAim() end)
  sBtn("Боты: "..(Cfg.Aim.TargetBots and "ВКЛ" or "ВЫКЛ"),function() Cfg.Aim.TargetBots=not Cfg.Aim.TargetBots; pgAim() end)
  sLbl("Поведение")
  sBtn("Авто-клик: "..(Cfg.Aim.AutoClick and "ВКЛ" or "ВЫКЛ"),function() Cfg.Aim.AutoClick=not Cfg.Aim.AutoClick; pgAim() end)
  sBtn("Круг FOV: "..(Cfg.Aim.ShowFOV and "ВКЛ" or "ВЫКЛ"),function() Cfg.Aim.ShowFOV=not Cfg.Aim.ShowFOV; Fn.updFov(); pgAim() end)
  sBtn("Режим наведения: "..(Cfg.Aim.UseMouse and "Мышь" or "Камера"),function() Cfg.Aim.UseMouse=not Cfg.Aim.UseMouse; pgAim() end)
  sLbl("FOV (радиус наведения): "..Cfg.Aim.FOV.." px")
  sBtn("Увеличить FOV (+10 px)",function() Cfg.Aim.FOV=math.min(600,Cfg.Aim.FOV+10); Fn.updFov(); pgAim() end)
  sBtn("Уменьшить FOV (−10 px)",function() Cfg.Aim.FOV=math.max(20,Cfg.Aim.FOV-10); Fn.updFov(); pgAim() end)
  sLbl("Плавность (smoothness): "..string.format("%.2f",Cfg.Aim.Smoothness))
  sBtn("Плавнее (+0.05) — медленнее сводит",function() Cfg.Aim.Smoothness=math.min(1,Cfg.Aim.Smoothness+0.05); pgAim() end)
  sBtn("Резче (−0.05) — быстрее сводит",function() Cfg.Aim.Smoothness=math.max(0.05,Cfg.Aim.Smoothness-0.05); pgAim() end)
  sLbl("Максимальная дистанция до цели: "..Cfg.Aim.MaxDistance.." studs")
  sBtn("Дальше (+100)",function() Cfg.Aim.MaxDistance=Cfg.Aim.MaxDistance+100; pgAim() end)
  sBtn("Ближе (−100)",function() Cfg.Aim.MaxDistance=math.max(100,Cfg.Aim.MaxDistance-100); pgAim() end)
  sLbl("Бинд включения")
  sBtn("Сейчас: "..bindName(Cfg.Aim.Bind).." — нажми, чтобы сменить",function() Fn.listenKey(UI.pt,"Aim",function(k) Cfg.Aim.Bind=k end,pgAim) end)
  sBtn("Сбросить бинд",function() Cfg.Aim.Bind=nil; Fn.refreshBinds(); pgAim() end)
end
local function oAim() if UI.pt.Text=="Aim" and UI.panel.Visible then Fn.closePanel() else pgAim() end end
do
  local r=createRow(Row.main,"Aim Assist","Наведение по цели в FOV")
  Fn.setAim=createToggle(r,false,function(v) Cfg.Aim.Enabled=v; Fn.updFov() end)
  createGear(r,oAim)
end

-- ============================================================
-- 14. ESP PAGE
-- ============================================================
local function pgESP()
  clrP(); UI.pt.Text="ESP"; UI.panel.Visible=true
  sLbl("Цели")
  sBtn("Игроки: "..(Cfg.ESP.ShowPlayers and "ВКЛ" or "ВЫКЛ"),function() Cfg.ESP.ShowPlayers=not Cfg.ESP.ShowPlayers; pgESP() end)
  sBtn("Боты: "..(Cfg.ESP.ShowBots and "ВКЛ" or "ВЫКЛ"),function() Cfg.ESP.ShowBots=not Cfg.ESP.ShowBots; pgESP() end)
  sLbl("Цвет подсветки")
  sSw("цвет: "..Cfg.ESP.Presets[findIdx(Cfg.ESP.Color,Cfg.ESP.Presets)].name,
    function() return Cfg.ESP.Color end,
    function() Cfg.ESP.Color=cycPre(Cfg.ESP.Color,-1) end,
    function() Cfg.ESP.Color=cycPre(Cfg.ESP.Color,1) end)
  sLbl("Дистанция видимости ESP: "..Cfg.ESP.MaxDistance.." studs")
  sBtn("Дальше (+100)",function() Cfg.ESP.MaxDistance=Cfg.ESP.MaxDistance+100; pgESP() end)
  sBtn("Ближе (−100)",function() Cfg.ESP.MaxDistance=math.max(100,Cfg.ESP.MaxDistance-100); pgESP() end)
  sLbl("Бинд включения")
  sBtn("Сейчас: "..bindName(Cfg.ESP.Bind).." — нажми, чтобы сменить",function() Fn.listenKey(UI.pt,"ESP",function(k) Cfg.ESP.Bind=k end,pgESP) end)
  sBtn("Сбросить бинд",function() Cfg.ESP.Bind=nil; Fn.refreshBinds(); pgESP() end)
end
local function oESP() if UI.pt.Text=="ESP" and UI.panel.Visible then Fn.closePanel() else pgESP() end end
do
  local r=createRow(Row.main,"ESP","Подсветка игроков/ботов")
  Fn.setESP=createToggle(r,false,function(v) Cfg.ESP.Enabled=v end)
  createGear(r,oESP)
end

-- ============================================================
-- 15. FLY PAGE
-- ============================================================
local function pgFly()
  clrP(); UI.pt.Text="Fly"; UI.panel.Visible=true
  sLbl("Скорость полёта: "..Cfg.Fly.Speed.." studs/сек")
  sBtn("Быстрее (+10)",function() Cfg.Fly.Speed=Cfg.Fly.Speed+10; pgFly() end)
  sBtn("Медленнее (−10)",function() Cfg.Fly.Speed=math.max(10,Cfg.Fly.Speed-10); pgFly() end)
  sBtn("Noclip (проход через стены): "..(Cfg.Fly.Noclip and "ВКЛ" or "ВЫКЛ"),function() Cfg.Fly.Noclip=not Cfg.Fly.Noclip; pgFly() end)
  sLbl("Управление:\nWASD — движение\nSpace — вверх\nLeftCtrl — вниз")
  sLbl("Бинд включения")
  sBtn("Сейчас: "..bindName(Cfg.Fly.Bind).." — нажми, чтобы сменить",function() Fn.listenKey(UI.pt,"Fly",function(k) Cfg.Fly.Bind=k end,pgFly) end)
  sBtn("Сбросить бинд",function() Cfg.Fly.Bind=nil; Fn.refreshBinds(); pgFly() end)
end
local function oFly() if UI.pt.Text=="Fly" and UI.panel.Visible then Fn.closePanel() else pgFly() end end
do
  local r=createRow(Row.main,"Fly + Noclip","Полёт (FLYUI: BV+BG)")
  Fn.setFly=createToggle(r,false,function(v) Cfg.Fly.Enabled=v; if Fn.updFly then Fn.updFly() end end)
  createGear(r,oFly)
end

-- ============================================================
-- 16. SPEED PAGE
-- ============================================================
local function pgSpeed()
  clrP(); UI.pt.Text="Speed"; UI.panel.Visible=true
  sLbl("WalkSpeed (скорость ходьбы): "..Cfg.Speed.Value)
  sBtn("Быстрее (+10)",function() Cfg.Speed.Value=math.min(500,Cfg.Speed.Value+10); pgSpeed() end)
  sBtn("Медленнее (−10)",function() Cfg.Speed.Value=math.max(16,Cfg.Speed.Value-10); pgSpeed() end)
  sBtn("Сильно быстрее (+50)",function() Cfg.Speed.Value=math.min(500,Cfg.Speed.Value+50); pgSpeed() end)
  sBtn("Сильно медленнее (−50)",function() Cfg.Speed.Value=math.max(16,Cfg.Speed.Value-50); pgSpeed() end)
  sLbl("Ползунок скорости")
  sSld(16,500,Cfg.Speed.Value,function(v) Cfg.Speed.Value=v end)
  sLbl("Бинд включения")
  sBtn("Сейчас: "..bindName(Cfg.Speed.Bind).." — нажми, чтобы сменить",function() Fn.listenKey(UI.pt,"Speed",function(k) Cfg.Speed.Bind=k end,pgSpeed) end)
  sBtn("Сбросить бинд",function() Cfg.Speed.Bind=nil; Fn.refreshBinds(); pgSpeed() end)
end
local function oSpeed() if UI.pt.Text=="Speed" and UI.panel.Visible then Fn.closePanel() else pgSpeed() end end
do
  local r=createRow(Row.main,"Speed","Ускорение персонажа")
  Fn.setSpeed=createToggle(r,false,function(v) Cfg.Speed.Enabled=v; if Fn.updSpeed then Fn.updSpeed() end end)
  createGear(r,oSpeed)
end

-- ============================================================
-- 17. FORCE JUMP PAGE
-- ============================================================
local function pgFJ()
  clrP(); UI.pt.Text="Force Jump"; UI.panel.Visible=true
  sLbl("Статус: "..(Cfg.ForceJump.Enabled and "ВКЛ" or "ВЫКЛ"))
  sBtn(Cfg.ForceJump.Enabled and "Выключить" or "Включить",function() Fn.setFJ(not Cfg.ForceJump.Enabled); pgFJ() end)
  sLbl("Сила прыжка (JumpPower): "..Cfg.ForceJump.Power)
  sBtn("Выше (+10)",function() Cfg.ForceJump.Power=math.min(500,Cfg.ForceJump.Power+10); pgFJ() end)
  sBtn("Ниже (−10)",function() Cfg.ForceJump.Power=math.max(20,Cfg.ForceJump.Power-10); pgFJ() end)
  sBtn("Сброс (100)",function() Cfg.ForceJump.Power=100; pgFJ() end)
  sLbl("Бинд включения")
  sBtn("Сейчас: "..bindName(Cfg.ForceJump.Bind).." — нажми, чтобы сменить",function() Fn.listenKey(UI.pt,"Force Jump",function(k) Cfg.ForceJump.Bind=k end,pgFJ) end)
  sBtn("Сбросить бинд",function() Cfg.ForceJump.Bind=nil; Fn.refreshBinds(); pgFJ() end)
end
local function oFJ() if UI.pt.Text=="Force Jump" and UI.panel.Visible then Fn.closePanel() else pgFJ() end end
do
  local r=createRow(Row.main,"Force Jump","Прыжок везде")
  Fn.setFJ=createToggle(r,false,function(v) Cfg.ForceJump.Enabled=v; if Fn.updFJ then Fn.updFJ() end end)
  createGear(r,oFJ)
end

-- ============================================================
-- 18. HITBOX PAGE
-- ============================================================
local function pgHB()
  clrP(); UI.pt.Text="Hitbox"; UI.panel.Visible=true
  sLbl("Статус: "..(Cfg.Hitbox.Enabled and "ВКЛ" or "ВЫКЛ"))
  sBtn(Cfg.Hitbox.Enabled and "Выключить" or "Включить",function() Fn.setHB(not Cfg.Hitbox.Enabled); pgHB() end)
  sBtn("Куб-маркер: "..(Cfg.Hitbox.ShowCube and "ВКЛ" or "ВЫКЛ"),function() Cfg.Hitbox.ShowCube=not Cfg.Hitbox.ShowCube; Fn.updHB(); pgHB() end)
  sLbl("Размер хитбокса: "..Cfg.Hitbox.Size.."x")
  sBtn("Больше (+1)",function() Cfg.Hitbox.Size=math.min(50,Cfg.Hitbox.Size+1); Fn.updHB(); pgHB() end)
  sBtn("Меньше (−1)",function() Cfg.Hitbox.Size=math.max(2,Cfg.Hitbox.Size-1); Fn.updHB(); pgHB() end)
  sBtn("Сброс (8x)",function() Cfg.Hitbox.Size=8; Fn.updHB(); pgHB() end)
  sLbl("Ползунок размера")
  sSld(2,50,Cfg.Hitbox.Size,function(v) Cfg.Hitbox.Size=v; Fn.updHB() end)
  sLbl("Прозрачность куба: "..string.format("%.2f",Cfg.Hitbox.Transparency))
  sBtn("Прозрачнее (+0.05)",function() Cfg.Hitbox.Transparency=math.min(0.95,Cfg.Hitbox.Transparency+0.05); Fn.updHB(); pgHB() end)
  sBtn("Плотнее (−0.05)",function() Cfg.Hitbox.Transparency=math.max(0,Cfg.Hitbox.Transparency-0.05); Fn.updHB(); pgHB() end)
  sLbl("Цвет куба")
  sSw("цвет: "..Cfg.ESP.Presets[findIdx(Cfg.Hitbox.Color,Cfg.ESP.Presets)].name,
    function() return Cfg.Hitbox.Color end,
    function() Cfg.Hitbox.Color=cycPre(Cfg.Hitbox.Color,-1); Fn.updHB() end,
    function() Cfg.Hitbox.Color=cycPre(Cfg.Hitbox.Color,1); Fn.updHB() end)
  sLbl("Дистанция поиска целей: "..Cfg.Hitbox.MaxDistance.." studs")
  sBtn("Дальше (+500)",function() Cfg.Hitbox.MaxDistance=Cfg.Hitbox.MaxDistance+500; pgHB() end)
  sBtn("Ближе (−500)",function() Cfg.Hitbox.MaxDistance=math.max(500,Cfg.Hitbox.MaxDistance-500); pgHB() end)
  sLbl("Бинд включения")
  sBtn("Сейчас: "..bindName(Cfg.Hitbox.Bind).." — нажми, чтобы сменить",function() Fn.listenKey(UI.pt,"Hitbox",function(k) Cfg.Hitbox.Bind=k end,pgHB) end)
  sBtn("Сбросить бинд",function() Cfg.Hitbox.Bind=nil; Fn.refreshBinds(); pgHB() end)
end
local function oHB() if UI.pt.Text=="Hitbox" and UI.panel.Visible then Fn.closePanel() else pgHB() end end
do
  local r=createRow(Row.main,"Real Hitbox","Увеличение + куб-маркер")
  Fn.setHB=createToggle(r,false,function(v) Cfg.Hitbox.Enabled=v; if Fn.updHB then Fn.updHB() end end)
  createGear(r,oHB)
end

-- ============================================================
-- 19. FULLBRIGHT + ANTI-AFK
-- ============================================================
local fbProps={"Ambient","OutdoorAmbient","Brightness","ClockTime","FogEnd","GlobalShadows","EnvironmentDiffuseScale","EnvironmentSpecularScale","ShadowSoftness","GeographicLatitude"}
local function enableFB()
  St.FB.saved={}
  for _,p in ipairs(fbProps) do pcall(function() St.FB.saved[p]=Lighting[p] end) end
  pcall(function()
    Lighting.Ambient=Color3.fromRGB(178,178,178)
    Lighting.OutdoorAmbient=Color3.fromRGB(178,178,178)
    Lighting.Brightness=3; Lighting.ClockTime=14; Lighting.FogEnd=100000
    Lighting.GlobalShadows=false; Lighting.EnvironmentDiffuseScale=1
    Lighting.EnvironmentSpecularScale=1; Lighting.ShadowSoftness=0
  end)
end
local function disableFB()
  for p,v in pairs(St.FB.saved) do pcall(function() Lighting[p]=v end) end
  St.FB.saved={}
end
Fn.updFB=function(v) if v then enableFB() else disableFB() end end

Fn.updAntiAFK=function(v)
  if v then
    if St.AntiAFK.conn then return end
    St.AntiAFK.conn=UIS.InputChanged:Connect(function() end)
    St.AntiAFK.conn2=task.spawn(function()
      while Cfg.AntiAFK do
        task.wait(30)
        if Cfg.AntiAFK then
          pcall(function()
            if VIM then VIM:SendMouseMoveEvent(Vector2.new(1,1),false) end
          end)
        end
      end
    end)
  else
    if St.AntiAFK.conn then St.AntiAFK.conn:Disconnect(); St.AntiAFK.conn=nil end
    if St.AntiAFK.conn2 then pcall(task.cancel,St.AntiAFK.conn2); St.AntiAFK.conn2=nil end
  end
end

do
  local r=createRow(Row.misc,"Fullbright","Постоянная яркость")
  createToggle(r,false,function(v) Cfg.Fullbright=v; Fn.updFB(v) end)
end
do
  local r=createRow(Row.misc,"Anti-AFK","Защита от кика за неактивность")
  createToggle(r,false,function(v) Cfg.AntiAFK=v; Fn.updAntiAFK(v) end)
end

-- ============================================================
-- 20. SPEED
-- ============================================================
local function spEnforce()
  if not Cfg.Speed.Enabled then return end
  local c=LP.Character; if not c then return end
  local h=c:FindFirstChildOfClass("Humanoid")
  if not h or h.Health<=0 then return end
  if h.WalkSpeed~=Cfg.Speed.Value then pcall(function() h.WalkSpeed=Cfg.Speed.Value end) end
end
local function hookSp(h)
  if not h then return end
  table.insert(St.Speed.cn,h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
    if Cfg.Speed.Enabled then pcall(function() h.WalkSpeed=Cfg.Speed.Value end) end
  end))
end
Fn.updSpeed=function()
  if Cfg.Speed.Enabled then
    if St.Speed.run then return end
    St.Speed.run=true
    for _,c in ipairs(St.Speed.cn) do pcall(function() c:Disconnect() end) end
    St.Speed.cn={}
    table.insert(St.Speed.cn,RS.Heartbeat:Connect(spEnforce))
    local c=LP.Character; if c then hookSp(c:FindFirstChildOfClass("Humanoid")) end
    spEnforce()
  else
    St.Speed.run=false
    for _,c in ipairs(St.Speed.cn) do pcall(function() c:Disconnect() end) end
    St.Speed.cn={}
    local c=LP.Character
    if c then local h=c:FindFirstChildOfClass("Humanoid"); if h then pcall(function() h.WalkSpeed=16 end) end end
  end
end

-- ============================================================
-- 21. FORCE JUMP
-- ============================================================
local function fjApply()
  if not Cfg.ForceJump.Enabled then return end
  local c=LP.Character; if not c then return end
  local h=c:FindFirstChildOfClass("Humanoid")
  if not h or h.Health<=0 then return end
  if not St.FJ.saved then St.FJ.saved={UJP=h.UseJumpPower,JP=h.JumpPower,JH=h.JumpHeight} end
  pcall(function() h.UseJumpPower=true; h.JumpPower=Cfg.ForceJump.Power; h.JumpHeight=Cfg.ForceJump.Power*0.5 end)
end
local function fjJump()
  if not Cfg.ForceJump.Enabled or Fn.isMenuOpen() then return end
  local c=LP.Character; if not c then return end
  local h=c:FindFirstChildOfClass("Humanoid"); local r=c:FindFirstChild("HumanoidRootPart")
  if not h or not r or h.Health<=0 then return end
  pcall(function()
    h.Jump=true; h:ChangeState(Enum.HumanoidStateType.Jumping)
    local v=r.AssemblyLinearVelocity
    r.AssemblyLinearVelocity=Vector3.new(v.X,math.max(v.Y,Cfg.ForceJump.Power),v.Z)
  end)
end
Fn.updFJ=function()
  if Cfg.ForceJump.Enabled then
    if St.FJ.run then return end
    St.FJ.run=true
    for _,c in ipairs(St.FJ.cn) do pcall(function() c:Disconnect() end) end
    St.FJ.cn={}
    table.insert(St.FJ.cn,RS.Stepped:Connect(fjApply))
    table.insert(St.FJ.cn,UIS.JumpRequest:Connect(fjJump))
    fjApply()
  else
    St.FJ.run=false
    for _,c in ipairs(St.FJ.cn) do pcall(function() c:Disconnect() end) end
    St.FJ.cn={}
    local c=LP.Character
    if c then local h=c:FindFirstChildOfClass("Humanoid")
      if h then pcall(function()
        if St.FJ.saved then h.UseJumpPower=St.FJ.saved.UJP; h.JumpPower=St.FJ.saved.JP; h.JumpHeight=St.FJ.saved.JH
        else h.UseJumpPower=true; h.JumpPower=50; h.JumpHeight=7.2 end
      end) end
    end
    St.FJ.saved=nil
  end
end

-- ============================================================
-- 22. FLY (из FLYUI)
-- ============================================================
local function setNC(s)
  local c=LP.Character; if not c then return end
  for _,p in ipairs(c:GetDescendants()) do
    if p:IsA("BasePart") then pcall(function() p.CanCollide=not s end) end
  end
end

local function startFly()
  local char = LP.Character
  if not char then return end
  local hrp = char:FindFirstChild("HumanoidRootPart")
  local hum = char:FindFirstChildOfClass("Humanoid")
  if not hrp or not hum then return end

  flyState.flying = true
  hum.PlatformStand = true

  local bv = Instance.new("BodyVelocity")
  bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
  bv.Velocity = Vector3.zero
  bv.P = 1250
  bv.Parent = hrp

  local bg = Instance.new("BodyGyro")
  bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
  bg.P = 10000
  bg.D = 500
  bg.CFrame = hrp.CFrame
  bg.Parent = hrp

  flyState.bv = bv
  flyState.bg = bg

  flyState.loop = task.spawn(function()
    while flyState.flying do
      RS.Heartbeat:Wait()
      local c = LP.Character
      if not c then break end
      local root = c:FindFirstChild("HumanoidRootPart")
      if not root or not flyState.bv or not flyState.bg then break end

      local cam = workspace.CurrentCamera
      local dir = Vector3.zero

      if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
      if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
      if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
      if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end

      if dir.Magnitude > 0 then
        flyState.bv.Velocity = dir.Unit * Cfg.Fly.Speed
      else
        flyState.bv.Velocity = Vector3.zero
      end

      flyState.bg.CFrame = cam.CFrame

      if Cfg.Fly.Noclip then setNC(true) end
    end
  end)
end

local function stopFly()
  flyState.flying = false
  if flyState.bv then flyState.bv:Destroy(); flyState.bv = nil end
  if flyState.bg then flyState.bg:Destroy(); flyState.bg = nil end
  if flyState.loop then pcall(task.cancel, flyState.loop); flyState.loop = nil end
  local char = LP.Character
  if char then
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
  end
  if Cfg.Fly.Noclip then setNC(false) end
end

Fn.updFly = function()
  if Cfg.Fly.Enabled then
    if not flyState.flying then startFly() end
  else
    if flyState.flying then stopFly() end
  end
end

-- ============================================================
-- 23. ESP
-- ============================================================
local function addESP(m)
  if not m or not m:IsA("Model") or m==LP.Character then return end
  if St.ESP.hl[m] and St.ESP.hl[m].Parent then return end
  if not m:FindFirstChildOfClass("Humanoid") then return end
  local h=Instance.new("Highlight"); h.Name="Falid_ESP"
  h.FillColor=Cfg.ESP.Color; h.OutlineColor=Cfg.ESP.Color
  h.FillTransparency=0.65; h.OutlineTransparency=0
  h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
  h.Adornee=m; h.Parent=m; St.ESP.hl[m]=h
end
local function rmESP(m) local h=St.ESP.hl[m]; if h then pcall(function() h:Destroy() end); St.ESP.hl[m]=nil end end
local function clrESP() for m in pairs(St.ESP.hl) do rmESP(m) end end
Fn.clrESP=clrESP
local function espTick()
  if not Cfg.ESP.Enabled then if next(St.ESP.hl) then clrESP() end return end
  local c=LP.Character; local mr=c and Fn.getRoot(c); if not mr then return end
  local maxD=Cfg.ESP.MaxDistance; local f={}
  if Cfg.ESP.ShowPlayers then
    for _,pl in ipairs(Players:GetPlayers()) do
      if pl~=LP and pl.Character then
        local r=Fn.getRoot(pl.Character)
        if r and (r.Position-mr.Position).Magnitude<=maxD then addESP(pl.Character); f[pl.Character]=true end
      end
    end
  end
  if Cfg.ESP.ShowBots then
    for _,m in ipairs(getBots()) do
      local r=Fn.getRoot(m)
      if r and (r.Position-mr.Position).Magnitude<=maxD then addESP(m); f[m]=true end
    end
  end
  for m,h in pairs(St.ESP.hl) do
    if not m.Parent or not m:FindFirstChildOfClass("Humanoid") or not f[m] then rmESP(m)
    else h.FillColor=Cfg.ESP.Color; h.OutlineColor=Cfg.ESP.Color end
  end
end
task.spawn(function() while task.wait(0.1) do pcall(espTick) end end)

-- ============================================================
-- 24. AIM
-- ============================================================
local function hasLOS(tp,tm)
  local o=Cam.CFrame.Position; local dir=tp.Position-o
  local p=RaycastParams.new(); p.FilterType=Enum.RaycastFilterType.Exclude
  p.FilterDescendantsInstances={LP.Character,Cam}; p.IgnoreWater=true
  local r=workspace:Raycast(o,dir,p)
  if not r then return true end
  local hit=r.Instance
  if hit==tp then return true end
  if tm and (hit:IsDescendantOf(tm) or hit==tm) then return true end
  return false
end
local function considerTarget(m,ctr,best,bd,mr)
  local h=m:FindFirstChildOfClass("Humanoid")
  if not h or h.Health<=0 then return best,bd end
  local r=Fn.getRoot(m); local hd=Fn.getHead(m)
  if not r or not hd then return best,bd end
  if (r.Position-mr.Position).Magnitude>Cfg.Aim.MaxDistance then return best,bd end
  local sp=Cam:WorldToViewportPoint(hd.Position)
  if sp.Z<=0 then return best,bd end
  local sv=Vector2.new(sp.X,sp.Y); local sd=(sv-ctr).Magnitude
  if sd<=Cfg.Aim.FOV and sd<bd then
    if hasLOS(hd,m) then return hd,sd end
  end
  return best,bd
end
local function getTarget()
  local c=LP.Character; local mr=c and Fn.getRoot(c); if not mr then return nil end
  local best,bd=nil,math.huge
  local ctr=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
  if Cfg.Aim.TargetPlayers then
    for _,pl in ipairs(Players:GetPlayers()) do
      if pl~=LP and pl.Character then
        best,bd=considerTarget(pl.Character,ctr,best,bd,mr)
      end
    end
  end
  if Cfg.Aim.TargetBots then
    for _,m in ipairs(getBots()) do
      best,bd=considerTarget(m,ctr,best,bd,mr)
    end
  end
  return best
end

local aimAcc=0; local autoClickCooldown=0
local function aimStep(dt)
  if not Cfg.Aim.Enabled then return end
  aimAcc=aimAcc+dt; if aimAcc<0.016 then return end; aimAcc=0
  local t=getTarget(); if not t then return end
  if Cfg.Aim.UseMouse then
    local sp=Cam:WorldToViewportPoint(t.Position)
    if sp.Z>0 then
      local ctr=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2)
      local dx=(sp.X-ctr.X); local dy=(sp.Y-ctr.Y)
      local k=Cfg.Aim.Smoothness
      pcall(function() if mousemoverel then mousemoverel(dx*k,dy*k) end end)
    end
  else
    local d=CFrame.lookAt(Cam.CFrame.Position,t.Position)
    Cam.CFrame=Cam.CFrame:Lerp(d,Cfg.Aim.Smoothness)
  end
  if Cfg.Aim.AutoClick then
    autoClickCooldown=autoClickCooldown+dt
    if autoClickCooldown>=0.05 then
      autoClickCooldown=0
      pcall(function()
        if VIM then
          VIM:SendMouseButtonEvent(Mouse.X,Mouse.Y,0,true,game,0)
          task.wait(0.02)
          VIM:SendMouseButtonEvent(Mouse.X,Mouse.Y,0,false,game,0)
        end
      end)
    end
  end
end
pcall(function() RS:BindToRenderStep("Falid_Aim",Enum.RenderPriority.Camera.Value+1,aimStep) end)

-- ============================================================
-- 25. TP
-- ============================================================
local tpHolder=Instance.new("Frame")
tpHolder.Size=UDim2.new(1,0,1,0); tpHolder.BackgroundTransparency=1
tpHolder.Parent=Row.tp

local tpHeader=Instance.new("Frame")
tpHeader.Size=UDim2.new(1,0,0,38); tpHeader.BackgroundTransparency=1
tpHeader.Parent=tpHolder

local tpTitle=Instance.new("TextLabel")
tpTitle.Size=UDim2.new(1,-100,1,0); tpTitle.BackgroundTransparency=1
tpTitle.Font=Enum.Font.GothamSemibold; tpTitle.Text="Игроки в игре"; tpTitle.TextSize=13
tpTitle.TextColor3=Color3.fromRGB(220,220,235); tpTitle.TextXAlignment=Enum.TextXAlignment.Left
tpTitle.Parent=tpHeader

local tpRef=Instance.new("TextButton")
tpRef.Size=UDim2.fromOffset(90,30); tpRef.Position=UDim2.new(1,-90,0,4)
tpRef.BackgroundColor3=Cfg.GUI.Accent; tpRef.Text="Обновить"
tpRef.Font=Enum.Font.GothamBold; tpRef.TextSize=12; tpRef.TextColor3=Color3.fromRGB(255,255,255)
tpRef.Parent=tpHeader
Instance.new("UICorner",tpRef).CornerRadius=UDim.new(0,6)
tpRef.MouseButton1Click:Connect(function()
  if Fn.refreshTP then Fn.refreshTP(true) end
  Fn.showToast("Список обновлён",Cfg.GUI.Accent)
end)

local tpScroll=Instance.new("ScrollingFrame")
tpScroll.BackgroundTransparency=1; tpScroll.BorderSizePixel=0
tpScroll.Position=UDim2.new(0,0,0,44)
tpScroll.Size=UDim2.new(1,0,1,-44); tpScroll.CanvasSize=UDim2.new(0,0,0,0)
tpScroll.ScrollBarThickness=6; tpScroll.ScrollBarImageColor3=Cfg.GUI.Accent
tpScroll.ScrollingDirection=Enum.ScrollingDirection.Y
tpScroll.ElasticBehavior=Enum.ElasticBehavior.Never
tpScroll.Parent=tpHolder
pcall(function() tpScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y end)
local tpL=Instance.new("UIListLayout"); tpL.Padding=UDim.new(0,6); tpL.Parent=tpScroll

local function tpTo(pl)
  if not pl or not pl.Character then Fn.showToast("Игрок не в игре",Color3.fromRGB(255,60,60)); return end
  local c=LP.Character; local mr=c and Fn.getRoot(c); local tr=Fn.getRoot(pl.Character)
  if not mr or not tr then Fn.showToast("Ошибка ТП",Color3.fromRGB(255,60,60)); return end
  pcall(function() mr.CFrame=CFrame.new(tr.Position+Vector3.new(0,3,3)) end)
  Fn.showToast("ТП → "..pl.Name,Cfg.GUI.Accent)
end

local function makeTpRow(pl)
  local r=Instance.new("Frame"); r.Name="row_"..pl.Name
  r.Size=UDim2.new(1,0,0,44)
  r.BackgroundColor3=Color3.fromRGB(30,30,40); r.BorderSizePixel=0; r.Parent=tpScroll
  Instance.new("UICorner",r).CornerRadius=UDim.new(0,8)
  local n=Instance.new("TextLabel"); n.BackgroundTransparency=1
  n.Position=UDim2.fromOffset(12,0); n.Size=UDim2.new(1,-100,1,0)
  n.Font=Enum.Font.GothamMedium; n.Text=pl.Name; n.TextSize=13
  n.TextColor3=Color3.fromRGB(230,230,245); n.TextXAlignment=Enum.TextXAlignment.Left; n.Parent=r
  local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(40,28)
  b.Position=UDim2.new(1,-84,0.5,-14); b.BackgroundColor3=Cfg.GUI.Accent
  b.Text="TP"; b.Font=Enum.Font.GothamBold; b.TextSize=12
  b.TextColor3=Color3.fromRGB(255,255,255); b.Parent=r
  Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
  b.MouseButton1Click:Connect(function() tpTo(pl) end)
end

Fn.refreshTP=function(force)
  for _,v in ipairs(tpScroll:GetChildren()) do
    if v:IsA("GuiObject") then v:Destroy() end
  end
  local players={}
  for _,pl in ipairs(Players:GetPlayers()) do
    if pl~=LP then table.insert(players,pl) end
  end
  tpTitle.Text = "Игроки в игре ("..#players..")"
  if #players==0 then
    local e=Instance.new("TextLabel")
    e.Size=UDim2.new(1,0,0,40); e.BackgroundTransparency=1
    e.Font=Enum.Font.Gotham; e.Text="Нет других игроков"; e.TextSize=13
    e.TextColor3=Color3.fromRGB(140,140,155); e.TextXAlignment=Enum.TextXAlignment.Center
    e.Parent=tpScroll
  else
    for _,pl in ipairs(players) do makeTpRow(pl) end
  end
end

Players.PlayerAdded:Connect(function() task.wait(0.3); Fn.refreshTP(true) end)
Players.PlayerRemoving:Connect(function() task.wait(0.3); Fn.refreshTP(true) end)

local _oldSwitchTab = Fn.switchTab
Fn.switchTab = function(n)
  _oldSwitchTab(n)
  if n=="tp" and Fn.refreshTP then
    task.defer(function() Fn.refreshTP(true) end)
  end
end

task.spawn(function()
  task.wait(1.5)
  Fn.refreshTP(true)
  while true do
    task.wait(1.5)
    if Tabs.tp and Tabs.tp.cont.Visible then
      Fn.refreshTP(false)
    end
  end
end)

-- ============================================================
-- 26. WORLD
-- ============================================================
local function clearW() for _,p in ipairs(St.W.wp) do pcall(function() p:Destroy() end) end St.W.wp={} end
local function clearWP() for _,p in ipairs(St.W.wpart) do pcall(function() p:Destroy() end) end St.W.wpart={} end

local function spawnWeather()
  clearW()
  if not Cfg.World.WeatherEnabled then return end
  local a,wt=Cfg.World.WeatherAmount,Cfg.World.WeatherType
  for i=1,a do
    local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false
    p.CanQuery=false; p.CanTouch=false; p.Massless=true; p.Material=Enum.Material.Neon
    if wt=="Rain" then p.Size=Vector3.new(0.1,1.5,0.1); p.Color=Color3.fromRGB(140,180,255); p.Transparency=0.4
    elseif wt=="Snow" then p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(0.3,0.3,0.3); p.Color=Color3.fromRGB(255,255,255); p.Transparency=0.2
    elseif wt=="Leaves" then p.Size=Vector3.new(0.6,0.1,0.4); p.Color=Color3.fromRGB(200,120,40); p.Transparency=0.1
    else p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(0.15,0.15,0.15); p.Color=Cfg.GUI.Accent; p.Transparency=0 end
    p.Parent=workspace; table.insert(St.W.wp,p)
  end
  task.spawn(function()
    while Cfg.World.WeatherEnabled do
      local c=LP.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
      if r then
        for _,p in ipairs(St.W.wp) do
          if p and p.Parent then
            local ang=math.random()*math.pi*2; local rd=math.random()*25+5
            p.CFrame=CFrame.new(r.Position+Vector3.new(math.cos(ang)*rd,math.random(15,45),math.sin(ang)*rd))
          end
        end
      end
      task.wait(0.3)
    end
  end)
end
Fn.spawnWeather=spawnWeather

local function spawnWP()
  clearWP()
  if not Cfg.World.WorldParticles then return end
  for i=1,40 do
    local p=Instance.new("Part"); p.Name="Falid_ParticleAnchor"
    p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false
    p.Massless=true; p.Transparency=1; p.Size=Vector3.new(1,1,1)
    p.Position=Vector3.new((math.random()-0.5)*1000,math.random(30,250),(math.random()-0.5)*1000)
    p.Parent=workspace
    local a=Instance.new("Attachment"); a.Parent=p
    local pe=Instance.new("ParticleEmitter")
    pe.Texture="rbxasset://textures/particles/sparkles_main.dds"
    pe.Rate=15; pe.Lifetime=NumberRange.new(3,6); pe.Speed=NumberRange.new(3,8)
    pe.SpreadAngle=Vector2.new(180,180); pe.Size=NumberSequence.new(0.5)
    pe.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.2),NumberSequenceKeypoint.new(1,1)})
    if Cfg.World.ParticleType=="Sparkles" then pe.Color=ColorSequence.new(Cfg.GUI.Accent)
    elseif Cfg.World.ParticleType=="Hearts" then pe.Color=ColorSequence.new(Color3.fromRGB(255,80,140))
    else pe.Color=ColorSequence.new(Color3.fromRGB(255,240,100)) end
    pe.Parent=a; table.insert(St.W.wpart,p)
  end
end
Fn.spawnWP=spawnWP

local function applyTime() if Cfg.World.TimeEnabled then pcall(function() Lighting.ClockTime=Cfg.World.ClockTime end) end end
local function applyFog()
  pcall(function()
    if Cfg.World.FogEnabled then
      Lighting.FogColor=Cfg.GUI.Accent; Lighting.FogStart=0; Lighting.FogEnd=Cfg.World.FogEnd
    else Lighting.FogStart=0; Lighting.FogEnd=100000 end
  end)
end
local function applyBright() if Cfg.World.BrightnessEnabled then pcall(function() Lighting.Brightness=Cfg.World.Brightness end) end end
Fn.applyTime=applyTime; Fn.applyFog=applyFog; Fn.applyBright=applyBright

local function pgWorld()
  clrP(); UI.pt.Text="World"; UI.panel.Visible=true
  sLbl("Время суток")
  sBtn("Активно: "..(Cfg.World.TimeEnabled and "ВКЛ" or "ВЫКЛ"),function() Cfg.World.TimeEnabled=not Cfg.World.TimeEnabled; applyTime(); pgWorld() end)
  sBtn("Утро (7:00)",function() Cfg.World.ClockTime=7; applyTime(); pgWorld() end)
  sBtn("День (14:00)",function() Cfg.World.ClockTime=14; applyTime(); pgWorld() end)
  sBtn("Вечер (18:00)",function() Cfg.World.ClockTime=18; applyTime(); pgWorld() end)
  sBtn("Ночь (0:00)",function() Cfg.World.ClockTime=0; applyTime(); pgWorld() end)
  sSld(0,24,Cfg.World.ClockTime,function(v) Cfg.World.ClockTime=v; applyTime() end)
  sLbl("Туман")
  sBtn("Активно: "..(Cfg.World.FogEnabled and "ВКЛ" or "ВЫКЛ"),function() Cfg.World.FogEnabled=not Cfg.World.FogEnabled; applyFog(); pgWorld() end)
  sLbl("Дальность тумана: "..Cfg.World.FogEnd.." studs")
  sBtn("Дальше (+200)",function() Cfg.World.FogEnd=math.min(5000,Cfg.World.FogEnd+200); applyFog(); pgWorld() end)
  sBtn("Ближе (−200)",function() Cfg.World.FogEnd=math.max(100,Cfg.World.FogEnd-200); applyFog(); pgWorld() end)
  sLbl("Яркость мира: "..string.format("%.1f",Cfg.World.Brightness))
  sBtn("Активно: "..(Cfg.World.BrightnessEnabled and "ВКЛ" or "ВЫКЛ"),function() Cfg.World.BrightnessEnabled=not Cfg.World.BrightnessEnabled; applyBright(); pgWorld() end)
  sBtn("Светлее (+0.5)",function() Cfg.World.Brightness=math.min(5,Cfg.World.Brightness+0.5); applyBright(); pgWorld() end)
  sBtn("Темнее (−0.5)",function() Cfg.World.Brightness=math.max(0,Cfg.World.Brightness-0.5); applyBright(); pgWorld() end)
  sLbl("Погода")
  sBtn("Активно: "..(Cfg.World.WeatherEnabled and "ВКЛ" or "ВЫКЛ"),function() Cfg.World.WeatherEnabled=not Cfg.World.WeatherEnabled; spawnWeather(); pgWorld() end)
  sBtn("Тип: "..Cfg.World.WeatherType,function()
    local l={"Rain","Snow","Leaves","Sparkles"}
    for i,t in ipairs(l) do if t==Cfg.World.WeatherType then Cfg.World.WeatherType=l[i%#l+1]; break end end
    spawnWeather(); pgWorld() end)
  sLbl("Количество частиц погоды: "..Cfg.World.WeatherAmount)
  sBtn("Больше (+10)",function() Cfg.World.WeatherAmount=math.min(200,Cfg.World.WeatherAmount+10); spawnWeather(); pgWorld() end)
  sBtn("Меньше (−10)",function() Cfg.World.WeatherAmount=math.max(10,Cfg.World.WeatherAmount-10); spawnWeather(); pgWorld() end)
  sLbl("Частицы по миру")
  sBtn("Активно: "..(Cfg.World.WorldParticles and "ВКЛ" or "ВЫКЛ"),function() Cfg.World.WorldParticles=not Cfg.World.WorldParticles; spawnWP(); pgWorld() end)
  sBtn("Тип: "..Cfg.World.ParticleType,function()
    local l={"Sparkles","Hearts","Stars"}
    for i,t in ipairs(l) do if t==Cfg.World.ParticleType then Cfg.World.ParticleType=l[i%#l+1]; break end end
    spawnWP(); pgWorld() end)
end
local function oWorld() if UI.pt.Text=="World" and UI.panel.Visible then Fn.closePanel() else pgWorld() end end

do
  local r1=createRow(Row.world,"Время суток","Day / Night")
  createToggle(r1,false,function(v) Cfg.World.TimeEnabled=v; applyTime() end)
  createGear(r1,oWorld)
  local r2=createRow(Row.world,"Туман","Дальность тумана")
  createToggle(r2,false,function(v) Cfg.World.FogEnabled=v; applyFog() end)
  createGear(r2,oWorld)
  local r3=createRow(Row.world,"Яркость","Освещение")
  createToggle(r3,false,function(v) Cfg.World.BrightnessEnabled=v; applyBright() end)
  createGear(r3,oWorld)
  local r4=createRow(Row.world,"Погода","Rain / Snow / Leaves / Sparkles")
  createToggle(r4,false,function(v) Cfg.World.WeatherEnabled=v; spawnWeather() end)
  createGear(r4,oWorld)
  local r5=createRow(Row.world,"Частицы в небе","Sparkles / Hearts / Stars")
  createToggle(r5,false,function(v) Cfg.World.WorldParticles=v; spawnWP() end)
  createGear(r5,oWorld)
end

-- ============================================================
-- 27. REAL HITBOX
-- ============================================================
local function restoreHB(m)
  local d=St.Hitbox.saved[m]; if not d then return end
  for p,info in pairs(d.parts) do
    if p and p.Parent then pcall(function()
      p.Size=info.s; p.Transparency=info.t; p.CanCollide=info.cc; p.Material=info.mt
    end) end
  end
  if d.cube then pcall(function() d.cube:Destroy() end) end
  local h=m:FindFirstChildOfClass("Humanoid")
  if h and d.hip then pcall(function() h.HipHeight=d.hip end) end
  St.Hitbox.saved[m]=nil
end
local function clearHB() for m in pairs(St.Hitbox.saved) do restoreHB(m) end end
Fn.clearHB=clearHB

local function applyHB(m)
  if not m or not m:IsA("Model") or m==LP.Character then return end
  local h=m:FindFirstChildOfClass("Humanoid")
  if not h or h.Health<=0 then return end
  local root=m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")
  if not root then return end
  local sc=math.max(1,Cfg.Hitbox.Size/4)
  local d=St.Hitbox.saved[m]
  if not d then
    d={parts={},hip=h.HipHeight,cube=nil}
    for _,p in ipairs(m:GetDescendants()) do
      if p:IsA("BasePart") then d.parts[p]={s=p.Size,t=p.Transparency,cc=p.CanCollide,mt=p.Material} end
    end
    St.Hitbox.saved[m]=d
  end
  for _,p in ipairs(m:GetDescendants()) do
    if p:IsA("BasePart") then
      local info=d.parts[p]
      if info then pcall(function()
        p.Size=Vector3.new(info.s.X*sc,info.s.Y*sc,info.s.Z*sc)
        p.Transparency=1; p.CanCollide=false; p.Massless=true
        p.CanQuery=true; p.CanTouch=true; p.Material=Enum.Material.ForceField
      end) end
    end
  end
  pcall(function() h.HipHeight=0 end)
  if Cfg.Hitbox.ShowCube then
    local sz=Cfg.Hitbox.Size
    if not d.cube or not d.cube.Parent then
      local cube=Instance.new("Part")
      cube.Name="Falid_HitboxCube"; cube.Shape=Enum.PartType.Block
      cube.Size=Vector3.new(sz,sz,sz); cube.CFrame=root.CFrame
      cube.Anchored=true; cube.CanCollide=false; cube.CanQuery=false; cube.CanTouch=false
      cube.Massless=true; cube.Material=Enum.Material.ForceField
      cube.Color=Cfg.Hitbox.Color; cube.Transparency=Cfg.Hitbox.Transparency
      cube.Parent=workspace; d.cube=cube
    else
      d.cube.Size=Vector3.new(sz,sz,sz); d.cube.CFrame=root.CFrame
      d.cube.Transparency=Cfg.Hitbox.Transparency; d.cube.Color=Cfg.Hitbox.Color
    end
  elseif d.cube then
    pcall(function() d.cube:Destroy() end); d.cube=nil
  end
end

local function hbTick()
  if not Cfg.Hitbox.Enabled then if next(St.Hitbox.saved) then clearHB() end return end
  local c=LP.Character
  local mr=c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
  if not mr then return end
  local maxD=Cfg.Hitbox.MaxDistance; local seen={}
  if Cfg.Hitbox.TargetPlayers then
    for _,pl in ipairs(Players:GetPlayers()) do
      if pl~=LP and pl.Character then
        local r=pl.Character:FindFirstChild("HumanoidRootPart")
        if r and (r.Position-mr.Position).Magnitude<=maxD then applyHB(pl.Character); seen[pl.Character]=true end
      end
    end
  end
  for m,d in pairs(St.Hitbox.saved) do
    if not m.Parent or not m:FindFirstChildOfClass("Humanoid") or not seen[m] then restoreHB(m)
    else
      local r=m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")
      if r and d.cube and d.cube.Parent then d.cube.CFrame=r.CFrame end
    end
  end
end
Fn.updHB=function()
  if Cfg.Hitbox.Enabled then
    if not St.Hitbox.conn then St.Hitbox.conn=RS.Heartbeat:Connect(function() pcall(hbTick) end) end
    pcall(hbTick)
  else
    if St.Hitbox.conn then St.Hitbox.conn:Disconnect(); St.Hitbox.conn=nil end
    clearHB()
  end
end

-- ============================================================
-- 28. KEYBINDS
-- ============================================================
Fn.refreshBinds=function() end
local bindMap={}
local function rebuildBindMap()
  bindMap={}
  local function add(b,fn)
    if not b then return end
    local k = typeof(b)=="EnumItem" and b.Name or tostring(b)
    bindMap[k]=fn
  end
  add(Cfg.GUI.ToggleBind,function()
    if UI.main.Visible then
      UI.main.Visible=false
      Fn.playToggle()
    else
      UI.main.Visible=true
      UI.main.BackgroundTransparency=Cfg.GUI.Transparency
      Fn.playMenu()
    end
  end)
  add(Cfg.Aim.Bind,function() Fn.setAim(not Cfg.Aim.Enabled) end)
  add(Cfg.ESP.Bind,function() Fn.setESP(not Cfg.ESP.Enabled) end)
  add(Cfg.Fly.Bind,function() Fn.setFly(not Cfg.Fly.Enabled) end)
  add(Cfg.Speed.Bind,function() Fn.setSpeed(not Cfg.Speed.Enabled) end)
  add(Cfg.ForceJump.Bind,function() Fn.setFJ(not Cfg.ForceJump.Enabled) end)
  add(Cfg.Hitbox.Bind,function() Fn.setHB(not Cfg.Hitbox.Enabled) end)
end
rebuildBindMap()

UIS.InputBegan:Connect(function(i,gp)
  if gp then return end
  local k
  if i.UserInputType==Enum.UserInputType.Keyboard then k=i.KeyCode.Name
  elseif isMouseBind(i) then k=i.UserInputType.Name
  else return end
  local fn=bindMap[k]
  if fn then
    rebuildBindMap()
    pcall(fn)
  end
end)

local _oldListen=Fn.listenKey
Fn.listenKey=function(title,restore,onK,onF)
  _oldListen(title,restore,function(k) onK(k); rebuildBindMap() end,onF)
end

-- ============================================================
-- 29. RESPAWN
-- ============================================================
LP.CharacterAdded:Connect(function()
  task.wait(0.6)
  St.FJ.saved=nil
  Fn.clearHB()
  if Cfg.ForceJump.Enabled then Fn.updFJ() end
  if Cfg.Fly.Enabled then
    flyState.flying = false
    if flyState.bv then flyState.bv:Destroy(); flyState.bv=nil end
    if flyState.bg then flyState.bg:Destroy(); flyState.bg=nil end
    if flyState.loop then pcall(task.cancel, flyState.loop); flyState.loop=nil end
    task.wait(0.3)
    Fn.updFly()
  end
  if Cfg.Speed.Enabled then St.Speed.run=false; Fn.updSpeed() end
  if Cfg.Hitbox.Enabled then Fn.updHB() end
  if Cfg.Fullbright then Fn.updFB(true) end
  Fn.clrESP()
end)

-- ============================================================
-- 30. LOADER ANIMATION
-- ============================================================
task.spawn(function()
  TS:Create(Ld.dark,TweenInfo.new(0.6),{BackgroundTransparency=0.45}):Play()
  for _,s in ipairs(Ld.list) do
    if not s.isT then
      task.spawn(function()
        if s.d>0 then task.wait(s.d) end
        s.f.BackgroundTransparency=0
        TS:Create(s.f,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.5}):Play()
        local cur=s.f.Position
        local tgt=UDim2.new(math.clamp(cur.X.Scale+s.dr.X,0,1),0,math.clamp(cur.Y.Scale+s.dr.Y,0,1),0)
        TS:Create(s.f,TweenInfo.new(3.5,Enum.EasingStyle.Linear),{Position=tgt}):Play()
      end)
    end
  end
  task.wait(0.3)
  for _,s in ipairs(Ld.list) do
    if s.isT then
      task.spawn(function()
        if s.d>0 then task.wait(s.d) end
        s.f.BackgroundTransparency=0
        TS:Create(s.f,TweenInfo.new(1.6+math.random(-20,40)/100,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
          {Position=UDim2.new(0.5,s.to.X,0.5,s.to.Y),Rotation=math.random(0,360)}):Play()
      end)
    end
  end
  task.wait(1.6)
  TS:Create(Ld.glow,TweenInfo.new(0.5),{TextTransparency=0.55}):Play()
  TS:Create(Ld.txt,TweenInfo.new(0.5),{TextTransparency=0}):Play()
  task.wait(0.6)
  for _,s in ipairs(Ld.list) do
    if s.isT then TS:Create(s.f,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play() end
  end
  task.wait(0.3)
  TS:Create(Ld.txt,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextSize=86}):Play()
  task.wait(0.2)
  TS:Create(Ld.txt,TweenInfo.new(0.3),{TextTransparency=1}):Play()
  TS:Create(Ld.glow,TweenInfo.new(0.3),{TextTransparency=1}):Play()
  TS:Create(Ld.dark,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
  for _,s in ipairs(Ld.list) do
    if not s.isT then TS:Create(s.f,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play() end
  end
  task.wait(0.4)
  Ld.dark:Destroy(); Ld.shards:Destroy(); Ld.txt:Destroy(); Ld.glow:Destroy()
  UI.main.Visible=true
  UI.main.BackgroundTransparency=Cfg.GUI.Transparency
  UI.main.Size=UDim2.fromOffset(560,368)
  TS:Create(UI.main,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
    {Size=UDim2.fromOffset(700,460)}):Play()
  TS:Create(UI.stroke,TweenInfo.new(0.35),{Transparency=0.25}):Play()
  Fn.playMenu()
end)

Fn.switchTab("main")
Fn.updFov()

print("[FALID] v3.2 FINAL loaded ✓ (без Portal Gun, без 'Другое', без Invisible)")
print("[FALID] Menu bind: "..bindName(Cfg.GUI.ToggleBind))
