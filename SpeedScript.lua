-- [[ Zero Absolute Control | Shadow Protocol ]] --
-- مخصص للسيطرة الكاملة على خرائط السرعة والهروب

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Zero System 💀 | Absolute Override", HidePremium = true, SaveConfig = false})

local AnnihilationTab = Window:MakeTab({
    Name = "السيطرة الشاملة",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

_G.MassSpeed = false
_G.AutoWin = false
_G.Noclip = false

-- 1. ميزة الاستحواذ على السرعة (Mass Touch)
-- تقوم بجمع كل نقطة سرعة في الخريطة في أجزاء من الثانية
AnnihilationTab:AddToggle({
    Name = "استحواذ كلي للسرعة (Mass Speed Farm)",
    Default = false,
    Callback = function(Value)
        _G.MassSpeed = Value
        task.spawn(function()
            while _G.MassSpeed do
                task.wait(0.1)
                pcall(function()
                    local RootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
                    -- البحث عن جميع كائنات اللمس المرتبطة بالسرعة في الخريطة
                    for _, item in pairs(workspace:GetDescendants()) do
                        if item:IsA("TouchTransmitter") then
                            local parentName = item.Parent.Name:lower()
                            if parentName:match("speed") or parentName:match("key") or parentName:match("part") then
                                -- إرسال إشارة وهمية للخادم بلمس العنصر
                                firetouchinterest(RootPart, item.Parent, 0)
                                firetouchinterest(RootPart, item.Parent, 1)
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- 2. ميزة احتكار الانتصارات (Auto Win/Trophies)
-- اختراق وتجاوز الخريطة والانتقال المباشر لخط النهاية بشكل متكرر
AnnihilationTab:AddToggle({
    Name = "احتكار الانتصارات (Auto Win Spam)",
    Default = false,
    Callback = function(Value)
        _G.AutoWin = Value
        task.spawn(function()
            while _G.AutoWin do
                task.wait(0.5)
                pcall(function()
                    local RootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
                    for _, block in pairs(workspace:GetDescendants()) do
                        -- البحث عن منصات النهاية أو الفوز
                        if block:IsA("Part") or block:IsA("MeshPart") then
                            local bName = block.Name:lower()
                            if bName:match("win") or bName:match("end") or bName:match("finish") or bName:match("reward") then
                                RootPart.CFrame = block.CFrame * CFrame.new(0, 3, 0)
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- 3. ميزة اختراق الجدران (Noclip)
-- تعطيل التصادم مع بيئة اللعبة لتجنب العوائق
AnnihilationTab:AddToggle({
    Name = "اختراق الجسيمات (Noclip)",
    Default = false,
    Callback = function(Value)
        _G.Noclip = Value
        game:GetService("RunService").Stepped:Connect(function()
            if _G.Noclip then
                pcall(function()
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end)
            end
        end)
    end
})

OrionLib:Init()
