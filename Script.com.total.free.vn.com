-- TOTAL HUB v1.000001 - by Thiên Anh
local Players,UIS,RS,Lighting,VirtualUser=game:GetService("Players"),game:GetService("UserInputService"),game:GetService("RunService"),game:GetService("Lighting"),game:GetService("VirtualUser")
local TeleportSvc,HttpSvc=game:GetService("TeleportService"),game:GetService("HttpService")
local Player=Players.LocalPlayer
local Mouse=Player:GetMouse()
local Camera=workspace.CurrentCamera
local Conn={} local S={} local SpeedVal=16
local function C(k) if Conn[k] then Conn[k]:Disconnect() Conn[k]=nil end end
local function GetH() local c=Player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function GetR() local c=Player.Character return c and c:FindFirstChild("HumanoidRootPart") end
-- GUI
local SG=Instance.new("ScreenGui") SG.Name="TotalHub" SG.ResetOnSpawn=false SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling SG.Parent=game:GetService("CoreGui")
local Main=Instance.new("Frame") Main.Size=UDim2.new(0,340,0,480) Main.Position=UDim2.new(0.5,-170,0.5,-240) Main.BackgroundColor3=Color3.fromRGB(0,20,40) Main.BorderSizePixel=0 Main.Active=true Main.Draggable=true Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,10)
local Border=Instance.new("UIStroke",Main) Border.Color=Color3.fromRGB(0,120,255) Border.Thickness=2
local Title=Instance.new("TextLabel",Main) Title.Size=UDim2.new(1,0,0,36) Title.BackgroundColor3=Color3.fromRGB(0,30,60) Title.BorderSizePixel=0 Title.Text="✦ THIÊN ANH ✦" Title.TextColor3=Color3.fromRGB(0,180,255) Title.TextScaled=true Title.Font=Enum.Font.GothamBold
Instance.new("UICorner",Title).CornerRadius=UDim.new(0,10)
local ToggleBtn=Instance.new("TextButton",Main) ToggleBtn.Size=UDim2.new(0,24,0,24) ToggleBtn.Position=UDim2.new(1,-28,0,6) ToggleBtn.BackgroundColor3=Color3.fromRGB(0,80,180) ToggleBtn.Text="—" ToggleBtn.TextColor3=Color3.new(1,1,1) ToggleBtn.Font=Enum.Font.GothamBold ToggleBtn.TextScaled=true ToggleBtn.BorderSizePixel=0
Instance.new("UICorner",ToggleBtn).CornerRadius=UDim.new(0,6)
local Body=Instance.new("ScrollingFrame",Main) Body.Size=UDim2.new(1,-10,1,-44) Body.Position=UDim2.new(0,5,0,40) Body.BackgroundTransparency=1 Body.BorderSizePixel=0 Body.ScrollBarThickness=3 Body.ScrollBarImageColor3=Color3.fromRGB(0,120,255) Body.CanvasSize=UDim2.new(0,0,0,0) Body.AutomaticCanvasSize=Enum.AutomaticSize.Y
local Layout=Instance.new("UIListLayout",Body) Layout.Padding=UDim.new(0,5) Layout.SortOrder=Enum.SortOrder.LayoutOrder
local Pad=Instance.new("UIPadding",Body) Pad.PaddingLeft=UDim.new(0,2) Pad.PaddingRight=UDim.new(0,2)
local menuOpen=true
ToggleBtn.MouseButton1Click:Connect(function()
    menuOpen=not menuOpen Body.Visible=menuOpen
    Main.Size=menuOpen and UDim2.new(0,340,0,480) or UDim2.new(0,340,0,36)
    ToggleBtn.Text=menuOpen and "—" or "+"
end)
local function MakeToggle(name,callback)
    local state=false
    local f=Instance.new("Frame",Body) f.Size=UDim2.new(1,-4,0,34) f.BackgroundColor3=Color3.fromRGB(0,30,55) f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",f).Color=Color3.fromRGB(0,70,140)
    local lbl=Instance.new("TextLabel",f) lbl.Size=UDim2.new(1,-50,1,0) lbl.Position=UDim2.new(0,10,0,0) lbl.BackgroundTransparency=1 lbl.Text=name lbl.TextColor3=Color3.fromRGB(200,230,255) lbl.Font=Enum.Font.Gotham lbl.TextScaled=true lbl.TextXAlignment=Enum.TextXAlignment.Left
    local btn=Instance.new("TextButton",f) btn.Size=UDim2.new(0,44,0,22) btn.Position=UDim2.new(1,-48,0.5,-11) btn.BackgroundColor3=Color3.fromRGB(0,60,120) btn.Text="OFF" btn.TextColor3=Color3.fromRGB(180,180,180) btn.Font=Enum.Font.GothamBold btn.TextScaled=true btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        state=not state
        btn.Text=state and "ON" or "OFF"
        btn.BackgroundColor3=state and Color3.fromRGB(0,180,80) or Color3.fromRGB(0,60,120)
        btn.TextColor3=state and Color3.new(1,1,1) or Color3.fromRGB(180,180,180)
        callback(state)
    end)
    return btn,function() return state end
end
local function MakeButton(name,callback)
    local btn=Instance.new("TextButton",Body) btn.Size=UDim2.new(1,-4,0,34) btn.BackgroundColor3=Color3.fromRGB(0,50,100) btn.Text=name btn.TextColor3=Color3.fromRGB(200,230,255) btn.Font=Enum.Font.GothamBold btn.TextScaled=true btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",btn).Color=Color3.fromRGB(0,100,200)
    btn.MouseButton1Click:Connect(callback)
end
local function MakeSep(txt)
    local f=Instance.new("Frame",Body) f.Size=UDim2.new(1,-4,0,20) f.BackgroundColor3=Color3.fromRGB(0,40,80) f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
    local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text="── "..txt.." ──" l.TextColor3=Color3.fromRGB(0,150,255) l.Font=Enum.Font.GothamBold l.TextScaled=true
end
local function Notify(msg)
    local ng=Instance.new("ScreenGui") ng.ResetOnSpawn=false ng.Parent=game:GetService("CoreGui")
    local nf=Instance.new("Frame",ng) nf.Size=UDim2.new(0,260,0,40) nf.Position=UDim2.new(0.5,-130,0,60) nf.BackgroundColor3=Color3.fromRGB(0,30,60) nf.BorderSizePixel=0
    Instance.new("UICorner",nf).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",nf).Color=Color3.fromRGB(0,120,255)
    local nl=Instance.new("TextLabel",nf) nl.Size=UDim2.new(1,0,1,0) nl.BackgroundTransparency=1 nl.Text=msg nl.TextColor3=Color3.new(1,1,1) nl.Font=Enum.Font.Gotham nl.TextScaled=true
    game:GetService("Debris"):AddItem(ng,2)
end
-- DI CHUYEN
MakeSep("Di Chuyển")
MakeButton("🛫 Bay Fly V3",function() loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyEvil/FlyV3/master/FlyV3.lua"))() Notify("Fly V3 đã load!") end)
MakeButton("🎯 Cấp TP Tool",function()
    if Player.Backpack:FindFirstChild("TP Tool") then Notify("Đã có rồi!") return end
    local t=Instance.new("Tool") t.Name="TP Tool" t.RequiresHandle=false t.Parent=Player.Backpack
    t.Activated:Connect(function() local r=GetR() if r and Mouse.Target then r.CFrame=CFrame.new(Mouse.Hit.Position+Vector3.new(0,5,0)) end end)
    Notify("TP Tool đã thêm!") end)
MakeToggle("🌀 Xuyên Tường",function(v) S.Noclip=v
    if v then Conn.Noclip=RS.Stepped:Connect(function() local c=Player.Character if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
    else C("Noclip") end Notify("Noclip: "..(v and "ON" or "OFF")) end)
MakeToggle("🐇 Nhảy Vô Hạn",function(v) S.InfJump=v Notify("Inf Jump: "..(v and "ON" or "OFF")) end)
UIS.JumpRequest:Connect(function() if S.InfJump then local h=GetH() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
MakeToggle("⚡ Speed x3",function(v)
    if v then SpeedVal=50 Conn.Speed=RS.Heartbeat:Connect(function() local h=GetH() if h then h.WalkSpeed=50 end end)
    else C("Speed") local h=GetH() if h then h.WalkSpeed=16 end end
    Notify("Speed: "..(v and "ON" or "OFF")) end)
MakeToggle("🪂 Trọng Lực Thấp",function(v) workspace.Gravity=v and 50 or 196 Notify("Low Gravity: "..(v and "ON" or "OFF")) end)
-- CHIEN DAU
MakeSep("Chiến Đấu")
MakeToggle("💀 Kill Aura",function(v) S.KillAura=v
    if v then Conn.KA=RS.Heartbeat:Connect(function()
        local r=GetR() if not r then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            local tr=p.Character:FindFirstChild("HumanoidRootPart")
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            if tr and h and h.Health>0 and (r.Position-tr.Position).Magnitude<=20 then
                pcall(function() h:TakeDamage(10) end) end end end end)
    else C("KA") end Notify("Kill Aura: "..(v and "ON" or "OFF")) end)
MakeToggle("📦 Hitbox Lớn",function(v)
    if v then Conn.HB=RS.Heartbeat:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then r.Size=Vector3.new(15,15,15) r.Transparency=0.7 end end end end)
    else C("HB") for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then r.Size=Vector3.new(2,2,1) r.Transparency=1 end end end end
    Notify("Hitbox: "..(v and "ON" or "OFF")) end)
MakeToggle("🛡️ Bất Tử",function(v) S.GodMode=v
    if v then Conn.God=RS.Heartbeat:Connect(function() local h=GetH() if h then h.Health=h.MaxHealth end end)
    else C("God") end Notify("God Mode: "..(v and "ON" or "OFF")) end)
MakeToggle("♻️ Tự Hồi Sinh",function(v) S.AutoRespawn=v
    if v then Conn.AR=RS.Heartbeat:Connect(function() local h=GetH()
        if h and h.Health<=0 then task.delay(0.5,function() Player:LoadCharacter() end) end end)
    else C("AR") end Notify("Auto Respawn: "..(v and "ON" or "OFF")) end)
MakeButton("☠️ Tự Sát",function() local h=GetH() if h then h.Health=0 end end)
-- HIEN THI
MakeSep("Hiển Thị")
MakeToggle("👁️ ESP Tên + Máu",function(v) S.ESP=v
    if v then
        local ESPFolder=Instance.new("Folder") ESPFolder.Name="ESP_TH" ESPFolder.Parent=workspace
        local function MakeESP(p)
            if p==Player then return end
            local function Build()
                local c=p.Character if not c then return end
                local r=c:FindFirstChild("HumanoidRootPart") if not r then return end
                local bb=Instance.new("BillboardGui") bb.Adornee=r bb.AlwaysOnTop=true bb.Size=UDim2.new(0,120,0,40) bb.StudsOffset=Vector3.new(0,3,0) bb.Parent=ESPFolder
                local nl=Instance.new("TextLabel",bb) nl.Size=UDim2.new(1,0,1,0) nl.BackgroundTransparency=1 nl.TextColor3=Color3.fromRGB(255,60,60) nl.TextStrokeTransparency=0 nl.Font=Enum.Font.GothamBold nl.TextScaled=true
                Conn["ESP_"..p.Name]=RS.Heartbeat:Connect(function()
                    local myR=GetR() local hum=c:FindFirstChildOfClass("Humanoid")
                    if hum and myR and r.Parent then
                        nl.Text=p.Name.."\n❤️"..math.floor(hum.Health).." | "..math.floor((myR.Position-r.Position).Magnitude).."m" end end)
            end
            p.CharacterAdded:Connect(Build) Build()
        end
        for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
        Conn.ESPAdd=Players.PlayerAdded:Connect(MakeESP)
    else
        for _,p in ipairs(Players:GetPlayers()) do C("ESP_"..p.Name) end
        C("ESPAdd") local f=workspace:FindFirstChild("ESP_TH") if f then f:Destroy() end
    end Notify("ESP: "..(v and "ON" or "OFF")) end)
MakeToggle("🌟 Fullbright",function(v)
    if v then Lighting.Brightness=10 Lighting.ClockTime=14 Lighting.FogEnd=1e6 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1)
    else Lighting.Brightness=1 Lighting.ClockTime=14 Lighting.FogEnd=1e4 Lighting.GlobalShadows=true Lighting.Ambient=Color3.new(0,0,0) end
    Notify("Fullbright: "..(v and "ON" or "OFF")) end)
-- QUAY PHA
MakeSep("Quậy Phá")
MakeButton("💥 Tung Tất Cả",function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            bv.Velocity=Vector3.new(math.random(-500,500),math.random(300,800),math.random(-500,500))
            bv.Parent=r game:GetService("Debris"):AddItem(bv,0.2) end end end
    Notify("Đã tung tất cả!") end)
MakeButton("👊 Đẩy Tất Cả",function()
    local myR=GetR() if not myR then return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            bv.Velocity=(r.Position-myR.Position).Unit*300+Vector3.new(0,100,0)
            bv.Parent=r game:GetService("Debris"):AddItem(bv,0.15) end end end
    Notify("Đã đẩy tất cả!") end)
MakeToggle("🌀 Xoay Liên Tục",function(v)
    if v then Conn.Spin=RS.Heartbeat:Connect(function() local r=GetR() if r then r.CFrame=r.CFrame*CFrame.Angles(0,math.rad(15),0) end end)
    else C("Spin") end Notify("Spin: "..(v and "ON" or "OFF")) end)
MakeToggle("🔥 Fling Walk",function(v)
    if v then Conn.FW=RS.Heartbeat:Connect(function()
        local r=GetR() if not r then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            local tr=p.Character:FindFirstChild("HumanoidRootPart")
            if tr and (r.Position-tr.Position).Magnitude<6 then
                local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e5,1e5,1e5)
                bv.Velocity=(tr.Position-r.Position).Unit*500+Vector3.new(0,200,0)
                bv.Parent=tr game:GetService("Debris"):AddItem(bv,0.1) end end end end)
    else C("FW") end Notify("Fling Walk: "..(v and "ON" or "OFF")) end)
-- TIEN ICH
MakeSep("Tiện Ích")
MakeToggle("🛡 Chống AFK",function(v)
    if v then Conn.AFK=Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.zero,Camera.CFrame) task.wait(0.1) VirtualUser:Button2Up(Vector2.zero,Camera.CFrame) end)
    else C("AFK") end Notify("Anti AFK: "..(v and "ON" or "OFF")) end)
MakeToggle("🕳️ Chống Rơi Vực",function(v) S.AntiVoid=v
    if v then Conn.AntiVoid=RS.Heartbeat:Connect(function() local r=GetR() if r and r.Position.Y<-100 then r.CFrame=CFrame.new(r.Position.X,10,r.Position.Z) end end)
    else C("AntiVoid") end Notify("Anti Void: "..(v and "ON" or "OFF")) end)
MakeToggle("👻 Tàng Hình",function(v)
    local c=Player.Character if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier=v and 1 or 0 end end
    Notify("Invisible: "..(v and "ON" or "OFF")) end)
MakeButton("🔄 Đổi Server",function()
    local ok,res=pcall(function() return HttpSvc:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if ok and res and res.data then for _,sv in ipairs(res.data) do
        if sv.id~=game.JobId and sv.playing<sv.maxPlayers then TeleportSvc:TeleportToPlaceInstance(game.PlaceId,sv.id,Player) return end end end
    Notify("Không tìm được server!") end)
MakeButton("🔁 Rejoin",function() TeleportSvc:Teleport(game.PlaceId,Player) end)
MakeButton("📋 Copy Remote",function()
    local list={} for _,v in ipairs(game:GetDescendants()) do if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then table.insert(list,v:GetFullName()) end end
    setclipboard(table.concat(list,"\n")) Notify("Đã copy "..#list.." remotes!") end)
MakeButton("🔧 F3X",function() pcall(function() loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)() end) Notify("F3X đã load!") end)
Notify("TOTAL HUB v1.000001 - Thiên Anh")
print("TOTAL HUB loaded!")
