-- [[ Shadow Hub V5.6 | Ultimate Bypass & Mobile Fix ]] --
-- المطور: Zero 👾 | مخصص لمختبر إلياس السري

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- مسح أي واجهة قديمة
if CoreGui:FindFirstChild("ShadowEliteV5") then
    CoreGui.ShadowEliteV5:Destroy()
end

-- ==========================================
-- 1. بناء الواجهة الاحترافية (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowEliteV5"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- زر 👽 (تم إصلاح التحريك للهواتف)
local AlienBtn = Instance.new("TextButton")
AlienBtn.Size = UDim2.new(0, 55, 0, 55)
AlienBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
AlienBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
AlienBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
AlienBtn.BorderSizePixel = 2
AlienBtn.Text = "👽"
AlienBtn.TextScaled = true
AlienBtn.Parent = ScreenGui
Instance.new("UICorner", AlienBtn).CornerRadius = UDim.new(1, 0)

-- الإطار الرئيسي
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 480)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- شريط العنوان للتحريك
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = " Shadow Hub V5.6 | Safe Arc"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- زر X لإغلاق القائمة
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- حاوية الأزرار
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 10)

-- ==========================================
-- 2. نظام التحريك المخصص للهواتف (Delta Fix)
-- ==========================================
local function MakeMobileDraggable(dragPart, movePart)
    local dragging = false
    local dragInput, mousePos, framePos

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

MakeMobileDraggable(AlienBtn, AlienBtn) -- جعل الزر الفضائي يتحرك
MakeMobileDraggable(TopBar, MainFrame)  -- جعل النافذة تتحرك من الشريط العلوي

AlienBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- ==========================================
-- 3. بناء الأزرار التفاعلية (ON/OFF)
-- ==========================================
local function CreateToggle(text, callback)
    local state = false
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- لون رمادي (OFF)
    Btn.Text = "❌ [OFF] " .. text
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80) -- أخضر (ON)
            Btn.Text = "✅ [ON] " .. text
        else
            Btn.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- أحمر (OFF)
            Btn.Text = "❌ [OFF] " .. text
        end
        callback(state)
    end)
end

local function CreateSlider(name, maxVal, callback)
    local Frame = Instance.new("Frame", Scroll)
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
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
-- 4. محرك السلامة والتخطي (Bypass & Arc)
-- ==========================================
_G.CharSpeed = 16
_G.CharJump = 50
_G.AutoWin = false
_G.AutoKeys = false
_G.AutoOrbs = false

-- تفعيل إزالة الفخاخ والوحوش لمنع الموت
local function CleanHazards()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:match("lava") or n:match("kill") or n:match("trap") or n:match("spike") then
                obj.CanCollide = false
                obj.Transparency = 0.5
            end
        end
    end
end

-- دالة القوس (Arc) لتفادي الـ Kick
local function SafeTeleport(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local startPos = root.CFrame.Position
    local endPos = targetCFrame.Position
    local midPos = (startPos + endPos) / 2 + Vector3.new(0, 30, 0) 

    for i = 0, 1, 0.05 do
        local p = (1-i)^2 * startPos + 2*(1-i)*i * midPos + i^2 * endPos
        root.CFrame = CFrame.new(p)
        task.wait(0.02)
    end
    char.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    root.CFrame = targetCFrame
end

RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.CharSpeed
            char.Humanoid.JumpPower = _G.CharJump
            if _G.AutoWin or _G.AutoKeys or _G.AutoOrbs then
                CleanHazards()
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
end)

CreateSlider("🏃 Speed Limit (آمن)", 480, function(val) _G.CharSpeed = val end)
CreateSlider("⬆️ Jump Limit", 480, function(val) _G.CharJump = val end)

-- ميزة 1: إكمال الباركور وتخطي العوائق (Auto Win)
CreateToggle("🏆 إكمال الباركور وتخطي العوائق", function(state)
    _G.AutoWin = state
    task.spawn(function()
        while _G.AutoWin do
            task.wait(0.5)
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoWin then break end
                    if obj:IsA("Part") or obj:IsA("MeshPart") then
                        local name = obj.Name:lower()
                        if name:match("win") or name:match("end") or name:match("reward") or obj.BrickColor.Name == "New Yeller" then
                            SafeTeleport(obj.CFrame * CFrame.new(0, 3, 0))
                            task.wait(1.5)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 2: الطيران المباشر للمفاتيح الذهبية
CreateToggle("🔑 انتقال مباشر للمفاتيح الذهبية", function(state)
    _G.AutoKeys = state
    task.spawn(function()
        while _G.AutoKeys do
            task.wait(1)
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoKeys then break end
                    if obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:match("key") or name:match("golden") or name:match("secret") then
                            SafeTeleport(obj.CFrame * CFrame.new(0, 0, -3))
                            task.wait(0.5)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 3: الطيران المباشر للكرات
CreateToggle("🟡 انتقال مباشر للكرات المتساقطة", function(state)
    _G.AutoOrbs = state
    task.spawn(function()
        while _G.AutoOrbs do
            task.wait(0.5)
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoOrbs then break end
                    if obj:IsA("BasePart") and obj:FindFirstChildWhichIsA("TouchTransmitter") then
                        local name = obj.Name:lower()
                        if name:match("orb") or obj.Material == Enum.Material.Neon then
                            SafeTeleport(obj.CFrame)
                        end
                    end
                end
            end)
        end
    end)
end)

print("Shadow Hub V5.6 Initialized - Zero 👾 Bypass Active")
