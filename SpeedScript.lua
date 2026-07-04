-- [[ Shadow Hub V4 | Elite Edition - Anti Ban & Auto Farm ]] --

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- مسح الواجهة القديمة لتجنب التكرار
if CoreGui:FindFirstChild("ShadowEliteV4") then
    CoreGui.ShadowEliteV4:Destroy()
end

-- ==========================================
-- 1. بناء الواجهة (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowEliteV4"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- زر 👽 المخفي
local AlienBtn = Instance.new("TextButton")
AlienBtn.Size = UDim2.new(0, 50, 0, 50)
AlienBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
AlienBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
AlienBtn.Text = "👽"
AlienBtn.TextScaled = true
AlienBtn.Parent = ScreenGui
Instance.new("UICorner", AlienBtn).CornerRadius = UDim.new(1, 0)

-- القائمة الرئيسية
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 480)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- شريط العنوان
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Shadow Hub V4 | Elite Anti-Ban"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- زر الإغلاق X
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 700)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 12)

-- ==========================================
-- 2. أنظمة السحب والتفاعل (Dragging Logic)
-- ==========================================
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    gui.Changed:Connect(function(prop)
        if prop == "AbsolutePosition" then dragInput = UserInputService:GetLastInputType() end
    end)
end

MakeDraggable(AlienBtn)
MakeDraggable(MainFrame)

AlienBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ==========================================
-- 3. دوال الأزرار المتقدمة (ON / OFF Toggles)
-- ==========================================
local function CreateToggle(text, callback)
    local state = false
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = "[OFF] " .. text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Btn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
            Btn.Text = "[ON] " .. text
        else
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Btn.Text = "[OFF] " .. text
        end
        callback(state)
    end)
    return Btn
end

local function CreateSlider(name, maxVal, callback)
    local Frame = Instance.new("Frame", Scroll)
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
    SliderBg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
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
-- 4. الأنظمة الأساسية (Features Logic)
-- ==========================================
_G.CharSpeed = 16
_G.CharJump = 50
_G.AutoKeys = false
_G.AutoOrbs = false
_G.SafeAutoRun = false

-- تطبيق السرعة بشكل متكرر
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.CharSpeed
            char.Humanoid.JumpPower = _G.CharJump
        end
    end)
end)

CreateSlider("🏃 Speed Limit (آمن)", 480, function(val) _G.CharSpeed = val end)
CreateSlider("⬆️ Jump Limit", 480, function(val) _G.CharJump = val end)

-- نظام سحب المفاتيح الذهبية عن بعد (مضاد للحظر)
CreateToggle("🔑 صيد المفاتيح الذهبية (عن بعد)", function(state)
    _G.AutoKeys = state
    task.spawn(function()
        while _G.AutoKeys do
            task.wait(0.5)
            pcall(function()
                local Root = LocalPlayer.Character.HumanoidRootPart
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj:FindFirstChildWhichIsA("TouchTransmitter") then
                        local name = obj.Name:lower()
                        -- استهداف المفاتيح دون الحاجة للطيران إليها
                        if name:match("key") or name:match("golden") or name:match("special") or name:match("secret") then
                            firetouchinterest(Root, obj, 0)
                            task.wait(0.05)
                            firetouchinterest(Root, obj, 1)
                        end
                    end
                end
            end)
        end
    end)
end)

-- نظام سحب الكرات الصفراء
CreateToggle("🟡 مغناطيس الكرات المتساقطة", function(state)
    _G.AutoOrbs = state
    task.spawn(function()
        while _G.AutoOrbs do
            task.wait(0.2)
            pcall(function()
                local Root = LocalPlayer.Character.HumanoidRootPart
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj:FindFirstChildWhichIsA("TouchTransmitter") then
                        local name = obj.Name:lower()
                        if name:match("orb") or obj.Material == Enum.Material.Neon then
                            firetouchinterest(Root, obj, 0)
                            task.wait(0.01)
                            firetouchinterest(Root, obj, 1)
                        end
                    end
                end
            end)
        end
    end)
end)

-- نظام الجري التلقائي للتقدم في العوالم
CreateToggle("🚶‍♂️ المشي التلقائي الآمن (اختراق العوالم)", function(state)
    _G.SafeAutoRun = state
    task.spawn(function()
        while _G.SafeAutoRun do
            task.wait()
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char.Humanoid
                local root = char.HumanoidRootPart
                
                -- إجبار الشخصية على الجري للأمام باستمرار لاختراق المراحل
                hum:Move(Vector3.new(0, 0, -1), true)
                
                -- القفز التلقائي في حال الاصطدام بعائق
                if hum.MoveDirection.Magnitude < 0.1 then
                    hum.Jump = true
                end
            end)
        end
    end)
end)

print("Shadow Elite V4 Initialized - By Zero 👾")
