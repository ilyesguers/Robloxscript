-- [[ Project: Phantom Strike | V2 ]] --
-- ميزات: Tween Teleport, 480 Max Speed/Jump, Native UI

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- مسح الواجهة القديمة إذا وجدت
if CoreGui:FindFirstChild("PhantomHub") then
    CoreGui.PhantomHub:Destroy()
end

-- ==========================================
-- 1. بناء الواجهة (Native UI - No Internet Required)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhantomHub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderColor3 = Color3.fromRGB(138, 43, 226) -- لون بنفسجي
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Phantom Hub | Speed & Teleport"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 5
Scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 10)

-- دالة إنشاء شريط تمرير (Slider)
local function CreateSlider(name, maxVal, callback)
    local Frame = Instance.new("Frame", Scroll)
    Frame.Size = UDim2.new(1, 0, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.5, 0, 0, 20)
    Label.Position = UDim2.new(0.05, 0, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": 16"
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local TextBox = Instance.new("TextBox", Frame)
    TextBox.Size = UDim2.new(0.3, 0, 0, 20)
    TextBox.Position = UDim2.new(0.65, 0, 0, 5)
    TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TextBox.TextColor3 = Color3.new(1,1,1)
    TextBox.Text = "16"
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)
    
    local SliderBg = Instance.new("TextButton", Frame)
    SliderBg.Size = UDim2.new(0.9, 0, 0, 10)
    SliderBg.Position = UDim2.new(0.05, 0, 0, 35)
    SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBg.Text = ""
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    
    local Fill = Instance.new("Frame", SliderBg)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
    
    local function UpdateVal(val)
        val = math.clamp(tonumber(val) or 16, 16, maxVal)
        TextBox.Text = tostring(math.floor(val))
        Label.Text = name .. ": " .. tostring(math.floor(val))
        Fill.Size = UDim2.new((val - 16) / (maxVal - 16), 0, 1, 0)
        callback(val)
    end
    
    TextBox.FocusLost:Connect(function() UpdateVal(TextBox.Text) end)
    
    local dragging = false
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            UpdateVal(16 + (pos * (maxVal - 16)))
        end
    end)
end

-- دالة لإنشاء زر (Button)
local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 2. الميزات والتحكم (Features Logic)
-- ==========================================

_G.CharSpeed = 16
_G.CharJump = 50
_G.Noclip = true -- تفعيل دائم لتفادي العوائق

-- الحفاظ على السرعة والقفز بشكل دائم (حتى لو غيرتها اللعبة)
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.CharSpeed
            char.Humanoid.JumpPower = _G.CharJump
        end
        -- نظام Noclip لتفادي الجدران
        if _G.Noclip and char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- شريط التحكم بالسرعة (حتى 480)
CreateSlider("Speed", 480, function(val)
    _G.CharSpeed = val
end)

-- شريط التحكم بالقفز (حتى 480)
CreateSlider("Jump", 480, function(val)
    _G.CharJump = val
end)

-- ==========================================
-- 3. نظام الانتقال الآمن (Tween Teleport / Bring)
-- ==========================================
-- هذه الدالة تقوم بتحريك اللاعب كأنه يطير بسرعة فائقة لتجنب كشف الـ Anti-Cheat
local function TweenTo(targetCFrame, duration)
    pcall(function()
        local Root = LocalPlayer.Character.HumanoidRootPart
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(Root, info, {CFrame = targetCFrame})
        tween:Play()
    end)
end

CreateButton("🚀 تجميع الجوائز الآمن (Tween Farm)", function()
    task.spawn(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and obj.Name:lower():match("win") then
                -- يحسب المسافة للتحكم بسرعة الانزلاق
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude
                local timeToReach = dist / 200 -- كلما زاد الرقم كان أسرع
                TweenTo(obj.CFrame * CFrame.new(0, 2, 0), timeToReach)
                task.wait(timeToReach + 0.1) -- ينتظر حتى يصل قبل الذهاب للتالي
            end
        end
    end)
end)

CreateButton("⚡ جمع كل السرعات في الخريطة", function()
    task.spawn(function()
        pcall(function()
            local Root = LocalPlayer.Character.HumanoidRootPart
            for _, item in pairs(workspace:GetDescendants()) do
                if item:IsA("TouchTransmitter") then
                    local pName = item.Parent.Name:lower()
                    if pName:match("speed") or pName:match("key") then
                        firetouchinterest(Root, item.Parent, 0)
                        firetouchinterest(Root, item.Parent, 1)
                    end
                end
            end
        end)
    end)
end)
