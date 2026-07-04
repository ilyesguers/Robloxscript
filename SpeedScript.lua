-- [[ Speed Keyboard Hub - المطور والمحدث بالكامل ]] --

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Speed Keyboard Hub 🚀 | Elite Edition", HidePremium = false, SaveConfig = true, ConfigFolder = "SpeedKeyboardConfig"})

-- المتغيرات العامة للتحكم في الميزات
_G.AutoFarm = false
_G.AutoRebirth = false
_G.AntiAFK = true
_G.WalkSpeed = 16
_G.JumpPower = 50

-- [[ ميزة الحماية من الطرد التلقائي - Anti AFK ]] --
if _G.AntiAFK then
    local VU = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new(0,0))
        OrionLib:MakeNotification({
            Name = "Anti-AFK",
            Content = "تم منع الطرد التلقائي بنجاح الحساب نشط الآن!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end)
end

-- [[ التبويب الأول: الميزات التلقائية الرئيسية ]] --
local MainTab = Window:MakeTab({
    Name = "تجميع تلقائي (Main)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- زر تفعيل التجميع التلقائي (Auto Farm)
MainTab:AddToggle({
    Name = "تفعيل التجميع التلقائي (Auto Farm)",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            task.spawn(function()
                while _G.AutoFarm do
                    -- الكود يقوم بالبحث عن منصات الأزرار (Keyboards) لزيادة السرعة تلقائياً
                    pcall(function()
                        local player = game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
                        if player and player:FindFirstChild("HumanoidRootPart") then
                            -- البحث عن العناصر التي تعطي سرعة في الخريطة ولمسها تلقائياً
                            for _, v in pairs(game.Workspace:GetChildren()) do
                                if v:IsA("Part") or v:IsA("MeshPart") then
                                    if v.Name:lower():find("key") or v.Name:lower():find("speed") then
                                        player.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 2, 0)
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end    
})

-- زر تفعيل التوليد التلقائي (Auto Rebirth)
MainTab:AddToggle({
    Name = "إعادة توليد تلقائي (Auto Rebirth)",
    Default = false,
    Callback = function(Value)
        _G.AutoRebirth = Value
        if Value then
            task.spawn(function()
                while _G.AutoRebirth do
                    -- إرسال طلب سيرفر للـ Rebirth تلقائياً عند توفر الشروط
                    pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Rebirth"):FireServer()
                    end)
                    task.wait(1)
                end
            end)
        end
    end    
})

-- [[ التبويب الثاني: تحسينات اللاعب ]] --
local PlayerTab = Window:MakeTab({
    Name = "تعديل اللاعب (Player)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- شريط التحكم في سرعة اللاعب
PlayerTab:AddSlider({
    Name = "تعديل السرعة (WalkSpeed)",
    Min = 16,
    Max = 500,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        _G.WalkSpeed = Value
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end    
})

-- حلقة تكرارية لضمان ثبات السرعة حتى بعد الموت أو الـ Rebirth
task.spawn(function()
    while true do
        pcall(function()
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                if game.Players.LocalPlayer.Character.Humanoid.WalkSpeed ~= _G.WalkSpeed then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = _G.WalkSpeed
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- شريط التحكم في قوة القفز
PlayerTab:AddSlider({
    Name = "قوة القفز (JumpPower)",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(80,120,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        _G.JumpPower = Value
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
    end    
})

-- [[ التبويب الثالث: الانتقال السريع ]] --
local TeleportTab = Window:MakeTab({
    Name = "انتقال سريع (Teleport)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddButton({
    Name = "الانتقال إلى البداية (Spawn)",
    Callback = function()
        pcall(function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Workspace:FindFirstChild("SpawnLocation").CFrame + Vector3.new(0,3,0)
        end)
    end
})

-- تفعيل الواجهة وإظهار إشعار الترحيب باللاعب
OrionLib:Init()
OrionLib:MakeNotification({
    Name = "تم تفعيل السكربت بنجاح! ⚡",
    Content = "مرحباً بك في Speed Keyboard Hub المحسن.",
    Image = "rbxassetid://4483345998",
    Time = 5
})
