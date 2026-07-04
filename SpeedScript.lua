-- [[ Shadow Hub V3 | Elite Edition - Safe Run & Event Sniper ]] --

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- مسح الواجهة القديمة لتجنب التكرار
if CoreGui:FindFirstChild("ShadowEliteV3") then
    CoreGui.ShadowEliteV3:Destroy()
end

-- ==========================================
-- 1. بناء واجهة زر 👽 السري (Draggable Toggle)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowEliteV3"
ScreenGui.Parent = CoreGui

local AlienBtn = Instance.new("TextButton")
AlienBtn.Size = UDim2.new(0, 50, 0, 50)
AlienBtn.Position = UDim2.new(0.5, -25, 0.1, 0)
AlienBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AlienBtn.Text = "👽"
AlienBtn.TextScaled = true
AlienBtn.Parent = ScreenGui
Instance.new("UICorner", AlienBtn).CornerRadius = UDim.new(1, 0) -- زر دائري

-- نظام تحريك زر 👽 (Dragging Logic)
local dragging, dragInput, dragStart, startPos
AlienBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = AlienBtn.Position
    end
end)
AlienBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        AlienBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
AlienBtn.Changed:Connect(function(prop)
    if prop == "AbsolutePosition" then dragInput = UserInputService:GetLastInputType() end
end)

-- ==========================================
-- 2. بناء القائمة الرئيسية (Main Menu)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Visible = false -- مخفية في البداية
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Shadow Hub | Safe Mode"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- فتح وإغلاق القائمة بالضغط على 👽
AlienBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 10)

-- ==========================================
-- 3. دوال إنشاء الأزرار (UI Functions)
-- ==========================================
local function CreateButton(text, color, callback)
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

local function CreateSlider(name, maxVal, callback)
    local Frame = Instance.new("Frame", Scroll)
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": 16"
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local SliderBg = Instance.new("TextButton", Frame)
    SliderBg.Size = UDim2.new(0.9, 0, 0, 10)
    SliderBg.Position = UDim2.new(0.05, 0, 0, 30)
    SliderBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SliderBg.Text = ""
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame", SliderBg)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function UpdateVal(input)
        local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(16 + (pos * (maxVal - 16)))
        Label.Text = name .. ": " .. tostring(val)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        callback(val)
    end
    
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; UpdateVal(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateVal(input) end
    end)
end

-- ==========================================
-- 4. المتغيرات والأنظمة المتقدمة (Logic)
-- ==========================================
_G.CharSpeed = 16
_G.CharJump = 50
_G.SafeAutoRun = false
_G.AutoOrbs = false

-- تطبيق السرعة بشكل آمن لمنع الاختراق
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.CharSpeed
            char.Humanoid.JumpPower = _G.CharJump
        end
    end)
end)

-- أشرطة التحكم بالسرعة والقفز (الحد 480)
CreateSlider("🏃 Speed Limit", 480, function(val) _G.CharSpeed = val end)
CreateSlider("⬆️ Jump Limit", 480, function(val) _G.CharJump = val end)

-- ميزة 1: صائد المفاتيح الذهبية (طيران ذكي وتخطي آمن)
CreateButton("🔑 جمع كل المفاتيح الذهبية (طيران)", Color3.fromRGB(200, 150, 0), function()
    task.spawn(function()
        pcall(function()
            local Root = LocalPlayer.Character.HumanoidRootPart
            local originalCFrame = Root.CFrame
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Part") or obj:IsA("MeshPart") then
                    local name = obj.Name:lower()
                    -- يبحث عن أي شيء اسمه مفتاح ذهبي أو مميز
                    if (name:match("golden") or name:match("key") or name:match("special")) and obj.Transparency < 1 then
                        
                        -- تفعيل اختراق الجدران فقط أثناء الطيران
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                        
                        -- الطيران نحو المفتاح
                        local dist = (Root.Position - obj.Position).Magnitude
                        local info = TweenInfo.new(dist / 250, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(Root, info, {CFrame = obj.CFrame})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0.2) -- ينتظر لحظة للتأكد من جمع المفتاح
                    end
                end
            end
            
            -- إعادة تفعيل الاصطدام بالجدران والعودة للأرض بأمان
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end)
    end)
end)

-- ميزة 2: جمع الكرات الصفراء عن بعد (بدون حركة)
local OrbBtn = CreateButton("🟡 تفعيل مغناطيس الكرات (Orbs)", Color3.fromRGB(0, 100, 200), function()
    _G.AutoOrbs = not _G.AutoOrbs
    task.spawn(function()
        while _G.AutoOrbs do
            task.wait(0.1)
            pcall(function()
                local Root = LocalPlayer.Character.HumanoidRootPart
                for _, obj in pairs(workspace:GetDescendants()) do
                    -- يبحث عن الكرات أو الأجسام المضيئة التي تسقط
                    if (obj:IsA("Part") or obj:IsA("MeshPart")) and obj:FindFirstChildWhichIsA("TouchTransmitter") then
                        if obj.Name:lower():match("orb") or obj.Shape == Enum.PartType.Ball or obj.Material == Enum.Material.Neon then
                            -- استدعاء اللمس عن بعد دون التحرك
                            firetouchinterest(Root, obj, 0)
                            firetouchinterest(Root, obj, 1)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 3: الجري التلقائي الآمن (يمشي على الأرض ويتفادى العوائق)
local WalkBtn = CreateButton("🚶‍♂️ المشي الآمن نحو الفوز (بدون بان)", Color3.fromRGB(0, 150, 0), function()
    _G.SafeAutoRun = not _G.SafeAutoRun
    task.spawn(function()
        while _G.SafeAutoRun do
            task.wait(0.1)
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char.Humanoid
                local root = char.HumanoidRootPart
                
                -- البحث عن منصات النهاية أو السرعة القريبة
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Part") and (obj.Name:lower():match("win") or obj.Name:lower():match("end")) then
                        -- جعل الشخصية تجري فعلياً نحو الهدف
                        hum:MoveTo(obj.Position)
                        
                        -- إذا توقفت الشخصية (بسبب عائق) تقفز تلقائياً
                        if hum.MoveDirection.Magnitude == 0 then
                            hum.Jump = true
                        end
                    end
                end
            end)
        end
    end)
end)

print("Shadow Elite V3 Loaded!")
