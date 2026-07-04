-- [[ Zero Absolute Control | Enhanced Protocol ]] --

-- إضافة نظام تنبيهات للتأكد من عمل السكريبت
local function SendNotification(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

-- محاولة تحميل مكتبة Orion
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
end)

if not success then
    warn("فشل تحميل مكتبة Orion: " .. tostring(OrionLib))
    SendNotification("خطأ", "فشل تحميل المكتبة. تأكد من اتصالك بالإنترنت أو دعم المحاكي.")
    return
end

local Window = OrionLib:MakeWindow({Name = "Zero System 💀 | Pro Version", HidePremium = true, SaveConfig = false})

-- التبويبات
local MainTab = Window:MakeTab({Name = "السيطرة", Icon = "rbxassetid://4483345998", PremiumOnly = false})

_G.MassSpeed = false
_G.AutoWin = false

-- 1. الميزة الأكثر طلباً: جمع السرعة التلقائي
MainTab:AddToggle({
    Name = "تجميع السرعة الكلي (Mass Farm)",
    Default = false,
    Callback = function(Value)
        _G.MassSpeed = Value
        if _G.MassSpeed then
            SendNotification("نظام", "بدأ تجميع السرعة...")
            task.spawn(function()
                while _G.MassSpeed do
                    task.wait(0.05) -- سرعة أكبر
                    pcall(function()
                        local RootPart = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if RootPart then
                            for _, item in pairs(workspace:GetDescendants()) do
                                if item:IsA("TouchTransmitter") and item.Parent then
                                    local pName = item.Parent.Name:lower()
                                    if pName:match("speed") or pName:match("key") then
                                        firetouchinterest(RootPart, item.Parent, 0)
                                        firetouchinterest(RootPart, item.Parent, 1)
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

-- 2. ميزة الفوز التلقائي (المعدلة لتكون أسرع)
MainTab:AddToggle({
    Name = "احتكار الفوز (Auto Finish)",
    Default = false,
    Callback = function(Value)
        _G.AutoWin = Value
        task.spawn(function()
            while _G.AutoWin do
                task.wait(0.3)
                pcall(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Part") and (obj.Name:match("End") or obj.Name:match("Finish")) then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame
                        end
                    end
                end)
            end
        end)
    end
})

OrionLib:Init()
SendNotification("تم بنجاح", "السكريبت يعمل الآن!")
