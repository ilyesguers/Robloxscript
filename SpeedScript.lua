-- [[ The Ultimate Shadow Hub | V1 - Native UI ]] --
-- لا يحتاج إلى إنترنت، مستقر 100%، ويحتوي على جميع الميزات الأسطورية

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- حذف الواجهة القديمة إذا تم تشغيل السكريبت مرتين لمنع التكرار
if CoreGui:FindFirstChild("ShadowHub") then
    CoreGui.ShadowHub:Destroy()
end

-- ==========================================
-- 1. بناء الواجهة الاحترافية (UI Construction)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHub"
ScreenGui.Parent = CoreGui

-- زر فتح/إغلاق القائمة
local ToggleMenuBtn = Instance.new("TextButton")
ToggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ToggleMenuBtn.BorderColor3 = Color3.fromRGB(80, 0, 255)
ToggleMenuBtn.BorderSizePixel = 2
ToggleMenuBtn.Text = "💀"
ToggleMenuBtn.TextScaled = true
ToggleMenuBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleMenuBtn).CornerRadius = UDim.new(0, 10)

-- الإطار الرئيسي للقائمة
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderColor3 = Color3.fromRGB(80, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- عنوان القائمة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "SHADOW HUB - ULTIMATE"
Title.TextColor3 = Color3.fromRGB(80, 150, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- منطقة التمرير للأزرار (Scroll Frame)
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- برمجة زر الفتح والإغلاق
local menuOpen = true
ToggleMenuBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
end)

-- ==========================================
-- 2. نظام المتغيرات والميزات (Features Logic)
-- ==========================================
_G.Settings = {
    AutoFarm = false,
    AutoWin = false,
    AutoRebirth = false,
    AntiAFK = false,
    Noclip = false,
    AntiLag = false
}

-- دالة لإنشاء أزرار التفعيل (Toggles)
local function CreateToggle(name, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.Text = text .. " [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = ScrollFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        _G.Settings[name] = not _G.Settings[name]
        if _G.Settings[name] then
            Btn.Text = text .. " [ON]"
            Btn.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            Btn.Text = text .. " [OFF]"
            Btn.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        callback(_G.Settings[name])
    end)
end

-- دالة لإنشاء أزرار المهام الفردية (Buttons)
local function CreateAction(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = ScrollFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
end

-- ==========================================
-- 3. الميزات الأسطورية (Legendary Features)
-- ==========================================

-- ميزة 1: الاستحواذ على جميع السرعات في الخريطة (Mass Farm)
CreateToggle("AutoFarm", "⚡ تجميع السرعة الشامل", function(state)
    task.spawn(function()
        while _G.Settings.AutoFarm do
            task.wait(0.1)
            pcall(function()
                local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if Root then
                    for _, item in pairs(workspace:GetDescendants()) do
                        if item:IsA("TouchTransmitter") and item.Parent then
                            local n = item.Parent.Name:lower()
                            if n:match("speed") or n:match("key") or n:match("part") then
                                firetouchinterest(Root, item.Parent, 0)
                                firetouchinterest(Root, item.Parent, 1)
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 2: الانتقال التلقائي للفوز واحتكار الجوائز (Auto Win)
CreateToggle("AutoWin", "🏆 احتكار الانتصارات", function(state)
    task.spawn(function()
        while _G.Settings.AutoWin do
            task.wait(0.5)
            pcall(function()
                local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if Root then
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Part") or obj:IsA("MeshPart") then
                            local n = obj.Name:lower()
                            if n:match("win") or n:match("end") or n:match("finish") then
                                Root.CFrame = obj.CFrame * CFrame.new(0, 2, 0)
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 3: اختراق الجدران والبيئة (Noclip)
CreateToggle("Noclip", "👻 اختراق الجدران (Noclip)", function(state)
    RunService.Stepped:Connect(function()
        if _G.Settings.Noclip then
            pcall(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 4: التوليد التلقائي الشامل (Auto Rebirth)
CreateToggle("AutoRebirth", "🔥 توليد تلقائي (Rebirth)", function(state)
    task.spawn(function()
        while _G.Settings.AutoRebirth do
            task.wait(1)
            pcall(function()
                -- يقوم بالبحث عن أي حدث Rebirth في اللعبة وتفعيله
                for _, remote in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                    if remote:IsA("RemoteEvent") and remote.Name:lower():match("rebirth") then
                        remote:FireServer()
                    end
                end
            end)
        end
    end)
end)

-- ميزة 5: منع الطرد من السيرفر (Anti-AFK)
CreateToggle("AntiAFK", "🛡️ حماية من الطرد (Anti-AFK)", function(state)
    if state then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- ميزة 6: تقليل اللاق وزيادة الفريمات (Anti-Lag FPS Boost)
CreateToggle("AntiLag", "🚀 تدمير اللاق (FPS Boost)", function(state)
    if state then
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj:Destroy()
                end
            end
            game.Lighting.GlobalShadows = false
            game.Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = 1
        end)
    end
end)

-- ميزة 7: تعديل سرعة اللاعب وقوة القفز يدوياً (Player Mods)
CreateAction("🏃 تفعيل سرعة خارقة يدوياً", function()
    pcall(function()
        LocalPlayer.Character.Humanoid.WalkSpeed = 250
        LocalPlayer.Character.Humanoid.JumpPower = 150
    end)
end)

CreateAction("🔄 إعادة ضبط سرعة اللاعب", function()
    pcall(function()
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end)
end)
