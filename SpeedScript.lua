-- تحضير المكتبات الأساسية
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- إنشاء واجهة تحكم (GUI) أسطورية وبسيطة
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local AntiAfkButton = Instance.new("TextButton")

ScreenGui.Name = "LegendarySpeedHub"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = true -- يمكنك تحريك القائمة في الشاشة

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Speed Keyboard Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14.000

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Position = UDim2.new(0.1, 0, 0.35, 0)
ToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Auto Farm : OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14.000

AntiAfkButton.Name = "AntiAfkButton"
AntiAfkButton.Parent = MainFrame
AntiAfkButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
AntiAfkButton.Position = UDim2.new(0.1, 0, 0.65, 0)
AntiAfkButton.Size = UDim2.new(0.8, 0, 0, 35)
AntiAfkButton.Font = Enum.Font.GothamBold
AntiAfkButton.Text = "Anti-AFK (On)"
AntiAfkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAfkButton.TextSize = 14.000

-- برمجة الميزات الأسطورية
local autoFarmRunning = false

-- ميزة التجميع التلقائي (Auto Farm)
ToggleButton.MouseButton1Click:Connect(function()
    autoFarmRunning = not autoFarmRunning
    if autoFarmRunning then
        ToggleButton.Text = "Auto Farm : ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        
        -- حلقة تكرار سريعة جداً للضغط التلقائي
        spawn(function()
            while autoFarmRunning do
                -- يحاكي الضغط العشوائي والسريع جداً على أزرار الكيبورد لرفع السرعة
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                task.wait(0.01)
                
                -- يمكنك إضافة المزيد من الأزرار إذا كان الماب يطلب أزراراً محددة
                local randomLetters = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
                local randomKey = randomLetters[math.random(1, #randomLetters)]
                VirtualInputManager:SendKeyEvent(true, randomKey, false, game)
                task.wait(0.01)
                VirtualInputManager:SendKeyEvent(false, randomKey, false, game)
            end
        end)
    else
        ToggleButton.Text = "Auto Farm : OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- ميزة منع الطرد بسبب الخمول (Anti-AFK)
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
