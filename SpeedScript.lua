-- [[ Shadow Hub V8.0 | Absolute Escape & Win Protocol ]] --
-- المطور: Zero 👾 | النسخة المحصنة والمعدلة بناءً على التحليل البصري

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("ShadowEliteV5") then
    CoreGui.ShadowEliteV5:Destroy()
end

-- ==========================================
-- 1. نظام الإشعارات الفوري
-- ==========================================
local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3
    })
end

-- ==========================================
-- 2. بناء الواجهة الاحترافية المتوافقة مع المشغل
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowEliteV5"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local AlienBtn = Instance.new("TextButton")
AlienBtn.Size = UDim2.new(0, 55, 0, 55)
AlienBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
AlienBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
AlienBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
AlienBtn.BorderSizePixel = 2
AlienBtn.Text = "👾"
AlienBtn.TextScaled = true
AlienBtn.Parent = ScreenGui
Instance.new("UICorner", AlienBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 520)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = " Shadow Hub V8.0 | Anti-Cheat Death Fix"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 700)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 10)

-- تحريك الواجهة للهواتف والمشغلات
local function MakeMobileDraggable(dragPart, movePart)
    local dragging, dragInput, mousePos, framePos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = movePart.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - mousePos
            movePart.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

MakeMobileDraggable(AlienBtn, AlienBtn)
MakeMobileDraggable(TopBar, MainFrame)

AlienBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local function CreateToggle(text, callback)
    local state = false
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = "❌ " .. text
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 70) or Color3.fromRGB(40, 40, 40)
        Btn.Text = (state and "✅ " or "❌ ") .. text
        callback(state)
    end)
end

-- ==========================================
-- 3. محرك التحييد والحركة المتقدم (Bypass Engine)
-- ==========================================
_G.AutoWin = false
_G.AutoKeys = false
_G.AutoOrbs = false
_G.AutoBoss = false

-- تنظيف الخريطة كلياً من مسببات الموت الفوري الموضحة في الفيديو
local function NeutralizeHazards()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:match("kill") or name:match("lava") or name:match("chocolate") or name:match("liquid") or name:match("mud") then
                obj.CanTouch = false -- إلغاء تفعيل خاصية القتل باللمس
                obj.CanCollide = false
            end
        end
    end
end

-- محرك الانزلاق الذكي (يحرك الأرجل، يمنع السقوط، ويحمي من الكشف)
local function EliteGlideTo(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    
    local root = char.HumanoidRootPart
    local hum = char.Humanoid
    
    -- رفع مسار اللاعب بمقدار 3 أسطر فوق الفخاخ لتجنب العوائق الفيزيائية
    local safeStartPos = root.Position
    local safeTargetPos = targetPos + Vector3.new(0, 4, 0)
    
    local distance = (safeTargetPos - safeStartPos).Magnitude
    local speed = 110 -- سرعة نُخبوية آمنة لا تسبب التجميد أو الطرد
    local duration = distance / speed
    local startTime = tick()
    
    -- إلغاء تصادم الجسد مع العوائق مؤقتاً أثناء الرحلة لمنع التعليق
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    -- تشغيل الرسوم المتحركة وحركة القدمين إجبارياً أثناء الانتقال
    local animFix = RunService.Heartbeat:Connect(function()
        if hum then 
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum:Move(Vector3.new(0, 0, -1), true)
        end
    end)
    
    while tick() - startTime < duration do
        if not _G.AutoWin and not _G.AutoKeys then break end
        local t = (tick() - startTime) / duration
        root.Velocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(safeStartPos:Lerp(safeTargetPos, t))
        task.wait()
    end
    
    if animFix then animFix:Disconnect() end
    root.CFrame = CFrame.new(targetPos) -- الهبوط الدقيق لتفعيل الـ Win
    task.wait(0.2)
end

-- ==========================================
-- 4. الميزات والبروتوكولات التنفيذية
-- ==========================================

-- ميزة 1: حصد الانتصارات الآمن (Auto Win Fix)
CreateToggle("🏆 إنهاء المراحل المستقر (مضمون + حرك القدمين)", function(state)
    _G.AutoWin = state
    if state then NeutralizeHazards() end
    task.spawn(function()
        while _G.AutoWin do
            task.wait(0.5)
            pcall(function()
                local winPart = nil
                -- البحث عن منصة النهاية الصحيحة القريبة من اللاعب أو المتوافقة مع المرحلة
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Part") or obj:IsA("MeshPart") then
                        local name = obj.Name:lower()
                        if (name:match("win") or name:match("end") or obj.BrickColor.Name == "New Yeller") and not obj:IsDescendantOf(char) then
                            winPart = obj
                            break
                        end
                    end
                end
                
                if winPart then
                    EliteGlideTo(winPart.Position)
                end
            end)
        end
    end)
end)

-- ميزة 2: رادار المفاتيح الذكي مع كاشف التوفر
CreateToggle("🔑 الانتقال للمفتاح الذهبي (مع فحص التوفر)", function(state)
    _G.AutoKeys = state
    task.spawn(function()
        while _G.AutoKeys do
            task.wait(1)
            pcall(function()
                local keyFound = false
                local targetKey = nil
                
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:match("key") or name:match("golden") or name:match("secret") then
                            keyFound = true
                            targetKey = obj
                            break
                        end
                    end
                end
                
                if keyFound and targetKey then
                    Notify("Zero 👾 System", "تم رصد المفتاح! جاري الانتقال الآمن...")
                    EliteGlideTo(targetKey.Position)
                    task.wait(1)
                elseif _G.AutoKeys then
                    Notify("Zero 👾 System", "تنبيه: المفتاح غير متوفر في الخريطة حالياً.")
                    task.wait(4) -- منع التكرار المزعج
                end
            end)
        end
    end)
end)

-- ميزة 3: الجذب المغناطيسي المطور لجميع أنواع الحلوى والقطع المتساقطة
CreateToggle("🟡 جذب الحلوى والكرات (رادار ممتد)", function(state)
    _G.AutoOrbs = state
    task.spawn(function()
        while _G.AutoOrbs do
            task.wait(0.2)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart
                
                -- مسح شامل للبحث عن أي عملة أو قطعة حلوى ملقاة تحتوي على مستشعر لمس
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoOrbs then break end
                    if obj:IsA("BasePart") and (obj:FindFirstChildWhichIsA("TouchTransmitter") or obj.Name:lower():match("candy") or obj.Name:lower():match("speed") or obj.Name:lower():match("orb")) then
                        firetouchinterest(root, obj, 0)
                        RunService.Heartbeat:Wait()
                        firetouchinterest(root, obj, 1)
                    end
                end
            end)
        end
    end)
end)

-- ميزة 4: آلة فرم الزعماء الوحشية لجمع الغنائم الضخمة
CreateToggle("⚔️ آلة فرم الزعماء (Boss Auto-Farm)", function(state)
    _G.AutoBoss = state
    task.spawn(function()
        while _G.AutoBoss do
            task.wait(0.1)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoBoss then break end
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and (obj.Name:lower():match("boss") or obj.Name:lower():match("monster")) then
                        if obj.Humanoid.Health > 0 then
                            local bossRoot = obj:FindFirstChild("HumanoidRootPart")
                            if bossRoot then
                                -- التموقع التلقائي في النقطة الميتة خلف ظهر الزعيم لحماية اللاعب
                                root.CFrame = bossRoot.CFrame * CFrame.new(0, 0, 4)
                                
                                -- تجهيز السلاح وتفعيله لفرمه فوراً
                                local tool = char:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                                if tool then
                                    tool.Parent = char
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- حلقة تكرارية للتأكد من استمرار إلغاء تفعيل الفخاخ حتى لو تغير العالم أو الخريطة
RunService.Stepped:Connect(function()
    if _G.AutoWin then
        pcall(NeutralizeHazards)
    end
end)

print("Shadow Hub V8.0 Activated Successfully.")
Notify("Zero 👾 System", "تم تحييد الفخاخ وتأمين محرك الحركة الطبيعية.")
