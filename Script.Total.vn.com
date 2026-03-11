-- TOTAL HUB v1.000001 - by Thiên Anh
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Players,UIS,RS,Lighting,VirtualUser=game:GetService("Players"),game:GetService("UserInputService"),game:GetService("RunService"),game:GetService("Lighting"),game:GetService("VirtualUser")
local TeleportSvc,HttpSvc=game:GetService("TeleportService"),game:GetService("HttpService")
local Player=Players.LocalPlayer
local Mouse=Player:GetMouse()
local Camera=workspace.CurrentCamera
local Conn={}
local S={}
local SpeedVal=16
local function C(k) if Conn[k] then Conn[k]:Disconnect() Conn[k]=nil end end
local function GetH() local c=Player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function GetR() local c=Player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local Window=Library:CreateWindow({Title='TOTAL HUB v1.000001',Center=true,AutoShow=true})
local Tabs={Main=Window:AddTab('Di Chuyển'),Combat=Window:AddTab('Chiến Đấu'),Visual=Window:AddTab('Hiển Thị'),Troll=Window:AddTab('Quậy Phá'),Misc=Window:AddTab('Tiện Ích')}
local function N(t,m) Library:Notify(t..'\n'..m,3) end
local MBox=Tabs.Main:AddLeftGroupbox('Di Chuyển')
MBox:AddButton('Bay Fly V3 Mobile',function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/LuckyEvil/FlyV3/master/FlyV3.lua"))()
    N("Fly V3","Đã load!") end)
MBox:AddButton('Cấp TP Tool',function()
    if Player.Backpack:FindFirstChild("TP Tool") then N("TP Tool","Đã có rồi!") return end
    local t=Instance.new("Tool") t.Name="TP Tool" t.RequiresHandle=false t.Parent=Player.Backpack
    t.Activated:Connect(function() local r=GetR() if r and Mouse.Target then r.CFrame=CFrame.new(Mouse.Hit.Position+Vector3.new(0,5,0)) end end)
    N("TP Tool","Đã thêm!") end)
MBox:AddToggle('Noclip',{Text='Xuyên Tường',Default=false,Callback=function(v) S.Noclip=v
    if v then Conn.Noclip=RS.Stepped:Connect(function() local c=Player.Character if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end)
    else C("Noclip") end end})
MBox:AddToggle('InfJump',{Text='Nhảy Vô Hạn',Default=false,Callback=function(v) S.InfJump=v end})
UIS.JumpRequest:Connect(function() if S.InfJump then local h=GetH() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
MBox:AddSlider('Speed',{Text='Tốc Độ Chạy',Default=16,Min=16,Max=500,Rounding=0,Callback=function(v) SpeedVal=v local h=GetH() if h then h.WalkSpeed=v end end})
MBox:AddToggle('SpeedLock',{Text='Khoá Tốc Độ',Default=false,Callback=function(v) S.SpeedLock=v
    if v then Conn.Speed=RS.Heartbeat:Connect(function() local h=GetH() if h then h.WalkSpeed=SpeedVal end end)
    else C("Speed") end end})
MBox:AddSlider('JumpPower',{Text='Lực Nhảy',Default=50,Min=50,Max=1000,Rounding=0,Callback=function(v) local h=GetH() if h then h.JumpPower=v end end})
MBox:AddSlider('Gravity',{Text='Trọng Lực',Default=196,Min=1,Max=500,Rounding=0,Callback=function(v) workspace.Gravity=v end})
local MBox2=Tabs.Main:AddRightGroupbox('Teleport')
local wpData={}
for i=1,3 do
    MBox2:AddButton('Lưu Vị Trí '..i,function()
        local r=GetR() if not r then return end
        wpData[i]=r.CFrame local p=r.Position
        N("Đã lưu "..i,"X="..math.floor(p.X).." Y="..math.floor(p.Y).." Z="..math.floor(p.Z)) end)
    MBox2:AddButton('TP Tới Vị Trí '..i,function()
        if not wpData[i] then N("Lỗi","Chưa lưu!") return end
        local r=GetR() if not r then return end
        r.CFrame=wpData[i]+Vector3.new(0,3,0) N("Đã TP","Tới vị trí "..i) end)
end
MBox2:AddButton('TP Tới Người Chơi Khác',function()
    local list={} for _,p in ipairs(Players:GetPlayers()) do if p~=Player then table.insert(list,p.Name) end end
    if #list==0 then N("Lỗi","Không có ai!") return end
    local p=Players:FindFirstChild(list[1])
    if p and p.Character then local r=GetR() local tr=p.Character:FindFirstChild("HumanoidRootPart")
        if r and tr then r.CFrame=tr.CFrame+Vector3.new(0,3,0) N("Đã TP","Đến: "..p.Name) end end end)
MBox2:AddButton('Về Điểm Xuất Phát',function()
    local r=GetR() if not r then return end
    local sp=workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then r.CFrame=sp.CFrame+Vector3.new(0,5,0) else r.CFrame=CFrame.new(0,10,0) end
    N("Về spawn","Đã TP!") end)
local CBox=Tabs.Combat:AddLeftGroupbox('Chiến Đấu')
local kaRadius=15
CBox:AddToggle('KillAura',{Text='Sát Thương Xung Quanh',Default=false,Callback=function(v) S.KillAura=v
    if v then Conn.KA=RS.Heartbeat:Connect(function()
        local r=GetR() if not r then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            local tr=p.Character:FindFirstChild("HumanoidRootPart")
            local h=p.Character:FindFirstChildOfClass("Humanoid")
            if tr and h and h.Health>0 and (r.Position-tr.Position).Magnitude<=kaRadius then
                pcall(function() local tool=Player.Character:FindFirstChildOfClass("Tool")
                    if tool then local re=tool:FindFirstChildOfClass("RemoteEvent") if re then re:FireServer(p.Character) end end end)
                pcall(function() h:TakeDamage(10) end) end end end end)
        N("Kill Aura ON","Bán kính: "..kaRadius)
    else C("KA") N("Kill Aura OFF","Đã tắt!") end end})
CBox:AddSlider('KARadius',{Text='Bán Kính Sát Thương',Default=15,Min=5,Max=100,Rounding=0,Callback=function(v) kaRadius=v end})
local hbSize=15 local origSizes={}
CBox:AddToggle('Hitbox',{Text='Phóng To Vùng Trúng Đòn',Default=false,Callback=function(v) S.Hitbox=v
    if v then Conn.HB=RS.Heartbeat:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            local root=p.Character:FindFirstChild("HumanoidRootPart")
            if root then if not origSizes[p.Name] then origSizes[p.Name]=root.Size end
                root.Size=Vector3.new(hbSize,hbSize,hbSize) root.Transparency=0.7 end end end end)
        N("Hitbox ON","Size: "..hbSize)
    else C("HB")
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            local root=p.Character:FindFirstChild("HumanoidRootPart")
            if root and origSizes[p.Name] then root.Size=origSizes[p.Name] root.Transparency=1 end end end
        origSizes={} N("Hitbox OFF","Đã phục hồi!") end end})
CBox:AddSlider('HBSize',{Text='Kích Thước Vùng Đòn',Default=15,Min=5,Max=100,Rounding=0,Callback=function(v) hbSize=v end})
local CBox2=Tabs.Combat:AddRightGroupbox('Nhân Vật')
CBox2:AddToggle('GodMode',{Text='Bất Tử',Default=false,Callback=function(v) S.GodMode=v
    if v then Conn.God=RS.Heartbeat:Connect(function() local h=GetH() if h then h.Health=h.MaxHealth end end)
    else C("God") end end})
CBox2:AddSlider('MaxHealth',{Text='Máu Tối Đa',Default=100,Min=100,Max=1000000,Rounding=0,Callback=function(v) local h=GetH() if h then h.MaxHealth=v h.Health=v end end})
CBox2:AddToggle('AutoRespawn',{Text='Hồi Sinh Tự Động',Default=false,Callback=function(v) S.AutoRespawn=v
    if v then Conn.AR=RS.Heartbeat:Connect(function() local h=GetH()
        if h and h.Health<=0 then task.delay(0.5,function() Player:LoadCharacter() end) end end)
    else C("AR") end end})
CBox2:AddToggle('InfStamina',{Text='Thể Lực Vô Hạn',Default=false,Callback=function(v) S.InfStamina=v
    if v then Conn.Stam=RS.Heartbeat:Connect(function() local c=Player.Character if not c then return end
        for _,val in ipairs(c:GetDescendants()) do if val:IsA("NumberValue") and val.Value<10 then
            local n=val.Name:lower() if n:find("stamina") or n:find("energy") or n:find("mana") then val.Value=100 end end end end)
    else C("Stam") end end})
CBox2:AddButton('Tự Sát',function() local h=GetH() if h then h.Health=0 end end)
local VBox=Tabs.Visual:AddLeftGroupbox('ESP')
local ESPFolder=Instance.new("Folder") ESPFolder.Name="ESP_TH" ESPFolder.Parent=workspace
local function MakeESP(p)
    if p==Player then return end
    local function Build()
        local c=p.Character if not c then return end
        local r=c:FindFirstChild("HumanoidRootPart") if not r then return end
        local old=ESPFolder:FindFirstChild("ESP_"..p.Name) if old then old:Destroy() end
        C("ESPTick_"..p.Name)
        local bb=Instance.new("BillboardGui") bb.Name="ESP_"..p.Name
        bb.Adornee=r bb.AlwaysOnTop=true bb.Size=UDim2.new(0,130,0,55) bb.StudsOffset=Vector3.new(0,4,0) bb.Parent=ESPFolder
        local nameL=Instance.new("TextLabel",bb) nameL.BackgroundTransparency=1
        nameL.Size=UDim2.new(1,0,0.5,0) nameL.TextColor3=Color3.fromRGB(255,60,60)
        nameL.TextStrokeTransparency=0 nameL.Font=Enum.Font.GothamBold nameL.TextScaled=true nameL.Text=p.Name
        local distL=Instance.new("TextLabel",bb) distL.BackgroundTransparency=1
        distL.Size=UDim2.new(1,0,0.3,0) distL.Position=UDim2.new(0,0,0.5,0)
        distL.TextColor3=Color3.fromRGB(255,220,80) distL.TextStrokeTransparency=0
        distL.Font=Enum.Font.Gotham distL.TextScaled=true
        local hpBG=Instance.new("Frame",bb) hpBG.BackgroundColor3=Color3.fromRGB(20,20,20)
        hpBG.Size=UDim2.new(1,0,0.15,0) hpBG.Position=UDim2.new(0,0,0.85,0) hpBG.BorderSizePixel=0
        local hpBar=Instance.new("Frame",hpBG) hpBar.BackgroundColor3=Color3.fromRGB(80,220,80)
        hpBar.Size=UDim2.new(1,0,1,0) hpBar.BorderSizePixel=0
        Conn["ESPTick_"..p.Name]=RS.Heartbeat:Connect(function()
            local myR=GetR()
            local hum=c:FindFirstChildOfClass("Humanoid")
            if hum and hpBar.Parent then
                local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                hpBar.Size=UDim2.new(pct,0,1,0)
                hpBar.BackgroundColor3=Color3.fromRGB(math.floor((1-pct)*255),math.floor(pct*220),50)
                distL.Text=math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
            end
            if myR and r.Parent then
                nameL.Text=p.Name.." ("..math.floor((myR.Position-r.Position).Magnitude).."m)"
            end end)
    end
    p.CharacterAdded:Connect(Build) Build()
end
VBox:AddToggle('ESP',{Text='ESP Tên + Máu + Khoảng Cách',Default=false,Callback=function(v) S.ESP=v
    if v then
        for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
        Conn.ESPAdd=Players.PlayerAdded:Connect(MakeESP)
        Conn.ESPRem=Players.PlayerRemoving:Connect(function(p) C("ESPTick_"..p.Name)
            local b=ESPFolder:FindFirstChild("ESP_"..p.Name) if b then b:Destroy() end end)
        N("ESP ON","Hiện tên + máu + khoảng cách!")
    else
        for _,p in ipairs(Players:GetPlayers()) do C("ESPTick_"..p.Name) end
        ESPFolder:ClearAllChildren() C("ESPAdd") C("ESPRem") N("ESP OFF","Đã tắt!") end end})
VBox:AddToggle('Chams',{Text='Xuyên Tường Màu',Default=false,Callback=function(v) S.Chams=v
    if v then Conn.Chams=RS.Heartbeat:Connect(function()
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            for _,pt in ipairs(p.Character:GetDescendants()) do
                if pt:IsA("BasePart") and not pt:FindFirstChildOfClass("SelectionBox") then
                    local sb=Instance.new("SelectionBox") sb.Adornee=pt
                    sb.Color3=Color3.fromRGB(255,0,0) sb.LineThickness=0.03
                    sb.SurfaceTransparency=0.7 sb.SurfaceColor3=Color3.fromRGB(255,80,80) sb.Parent=pt end end end end end)
    else C("Chams") for _,p in ipairs(Players:GetPlayers()) do if p.Character then
        for _,pt in ipairs(p.Character:GetDescendants()) do
            local sb=pt:FindFirstChildOfClass("SelectionBox") if sb then sb:Destroy() end end end end end end})
local VBox2=Tabs.Visual:AddRightGroupbox('Ánh Sáng')
local LDef={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,FogEnd=Lighting.FogEnd,GlobalShadows=Lighting.GlobalShadows,Ambient=Lighting.Ambient}
VBox2:AddToggle('Fullbright',{Text='Sáng Toàn Màn Hình',Default=false,Callback=function(v)
    if v then Lighting.Brightness=10 Lighting.ClockTime=14 Lighting.FogEnd=1e6 Lighting.GlobalShadows=false Lighting.Ambient=Color3.new(1,1,1)
    else for k,val in pairs(LDef) do Lighting[k]=val end end end})
VBox2:AddSlider('FOV',{Text='Góc Nhìn FOV',Default=70,Min=30,Max=120,Rounding=0,Callback=function(v) Camera.FieldOfView=v end})
local TBox=Tabs.Troll:AddLeftGroupbox('Troll')
TBox:AddButton('Tung Tất Cả Lên Trời',function()
    for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            bv.Velocity=Vector3.new(math.random(-500,500),math.random(300,800),math.random(-500,500))
            bv.Parent=r game:GetService("Debris"):AddItem(bv,0.2) end end end
    N("Fling!","Đã tung tất cả!") end)
TBox:AddButton('Đẩy Tất Cả Ra Xa',function()
    local myR=GetR() if not myR then return end
    for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
        local r=p.Character:FindFirstChild("HumanoidRootPart")
        if r then local dir=(r.Position-myR.Position).Unit
            local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            bv.Velocity=dir*300+Vector3.new(0,100,0)
            bv.Parent=r game:GetService("Debris"):AddItem(bv,0.15) end end end
    N("Đẩy!","Đã đẩy tất cả!") end)
local spinOn=false
TBox:AddButton('Xoay Liên Tục',function()
    spinOn=not spinOn
    if spinOn then Conn.Spin=RS.Heartbeat:Connect(function()
        local r=GetR() if not r then return end
        r.CFrame=r.CFrame*CFrame.Angles(0,math.rad(15),0) end)
        N("Spin ON","Đang xoay!")
    else C("Spin") N("Spin OFF","Đã dừng!") end end)
local lagOn=false
TBox:AddToggle('LagSwitch',{Text='Giật Lag',Default=false,Callback=function(v) lagOn=v
    if v then task.spawn(function() while lagOn do
        local t={} for i=1,300 do local p=Instance.new("Part") p.Anchored=true p.Parent=workspace table.insert(t,p) end
        task.wait(0.01) for _,p in ipairs(t) do p:Destroy() end task.wait(0.05) end end)
        N("Lag ON","Cẩn thận bị kick!")
    else N("Lag OFF","Đã tắt!") end end})
local TBox2=Tabs.Troll:AddRightGroupbox('Fling Walk')
local flingOn=false
TBox2:AddToggle('FlingWalk',{Text='Fling Walk Đụng Là Văng',Default=false,Callback=function(v) flingOn=v
    if v then Conn.FW=RS.Heartbeat:Connect(function()
        local r=GetR() if not r then return end
        for _,p in ipairs(Players:GetPlayers()) do if p~=Player and p.Character then
            local tr=p.Character:FindFirstChild("HumanoidRootPart")
            if tr and (r.Position-tr.Position).Magnitude<6 then
                local bv=Instance.new("BodyVelocity") bv.MaxForce=Vector3.new(1e5,1e5,1e5)
                local dir=(tr.Position-r.Position).Unit
                bv.Velocity=dir*500+Vector3.new(0,200,0)
                bv.Parent=tr game:GetService("Debris"):AddItem(bv,0.1) end end end end)
        N("Fling Walk ON","Đụng vào người là văng!")
    else C("FW") N("Fling Walk OFF","Đã tắt!") end end})
local MiscBox=Tabs.Misc:AddLeftGroupbox('Server')
MiscBox:AddButton('Đổi Server Hop',function()
    local ok,res=pcall(function()
        return HttpSvc:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if ok and res and res.data then for _,sv in ipairs(res.data) do
        if sv.id~=game.JobId and sv.playing<sv.maxPlayers then TeleportSvc:TeleportToPlaceInstance(game.PlaceId,sv.id,Player) return end end end
    N("Lỗi","Không tìm được server!") end)
MiscBox:AddButton('Vào Lại Server Rejoin',function() TeleportSvc:Teleport(game.PlaceId,Player) end)
MiscBox:AddButton('Copy Toàn Bộ Remote',function()
    local list={} for _,v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then table.insert(list,v:GetFullName()) end end
    setclipboard(table.concat(list,"\n")) N("Remotes","Đã copy "..#list.." remotes!") end)
MiscBox:AddButton('Copy ID Server',function()
    setclipboard("PlaceId: "..game.PlaceId.."\nJobId: "..game.JobId) N("Đã copy!","PlaceId & JobId") end)
MiscBox:AddButton('F3X Xây Dựng',function()
    pcall(function() loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)() end) N("F3X","Đã load!") end)
local MiscBox2=Tabs.Misc:AddRightGroupbox('Khác')
MiscBox2:AddToggle('AntiAFK',{Text='Chống AFK',Default=false,Callback=function(v)
    if v then Conn.AFK=Player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.zero,Camera.CFrame) task.wait(0.5)
        VirtualUser:Button2Up(Vector2.zero,Camera.CFrame) end)
    else C("AFK") end end})
MiscBox2:AddToggle('AntiVoid',{Text='Chống Rơi Vực',Default=false,Callback=function(v) S.AntiVoid=v
    if v then Conn.AntiVoid=RS.Heartbeat:Connect(function()
        local r=GetR() if not r then return end
        if r.Position.Y<-100 then r.CFrame=CFrame.new(r.Position.X,10,r.Position.Z) end end)
    else C("AntiVoid") end end})
MiscBox2:AddToggle('AntiKick',{Text='Chống Bị Đá',Default=false,Callback=function(v) S.AntiKick=v
    if v then pcall(function()
        local mt=getrawmetatable(game) local old=mt.__namecall
        mt.__namecall=newcclosure(function(self,...)
            local args={...} local method=args[#args]
            if method=="Kick" and self==Player and S.AntiKick then return end
            return old(self,...) end) end)
        N("Anti Kick ON","Chặn kick!")
    else N("Anti Kick OFF","Cần rejoin để xoá hook") end end})
MiscBox2:AddToggle('Invisible',{Text='Tàng Hình',Default=false,Callback=function(v)
    local c=Player.Character if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.LocalTransparencyModifier=v and 1 or 0 end end end})
Player.CharacterAdded:Connect(function()
    task.wait(1)
    if S.SpeedLock then C("Speed") Conn.Speed=RS.Heartbeat:Connect(function() local h=GetH() if h then h.WalkSpeed=SpeedVal end end) end
    if S.GodMode then C("God") Conn.God=RS.Heartbeat:Connect(function() local h=GetH() if h then h.Health=h.MaxHealth end end) end
    if S.Noclip then C("Noclip") Conn.Noclip=RS.Stepped:Connect(function() local c=Player.Character if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end) end
    if S.ESP then for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end end
    if S.AntiVoid then C("AntiVoid") Conn.AntiVoid=RS.Heartbeat:Connect(function()
        local r=GetR() if not r then return end
        if r.Position.Y<-100 then r.CFrame=CFrame.new(r.Position.X,10,r.Position.Z) end end) end
end)
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs.Misc)
ThemeManager:ApplyToTab(Tabs.Misc)
N("TOTAL HUB v1.000001","5 tab - Load xong!")
print("TOTAL HUB v1.000001 loaded!")
