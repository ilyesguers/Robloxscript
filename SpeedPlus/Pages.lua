--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 5) Pages — إنشاء الصفحات الثماني + الرئيسية والإعدادات
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Lib = SP.Lib
local Theme = SP.Theme
local Utils = SP.Utils
local Config = SP.Config
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================================
-- إنشاء كل الصفحات بألوانها
-- ==========================================================
local Pages = SP.Pages

Pages.Home = Lib.CreatePage("Home", "الرئيسية", Theme.Pages.Home.Icon, Theme.Pages.Home.Color, Theme.Pages.Home.Color2)
Pages.Speed = Lib.CreatePage("Speed", "السرعة", Theme.Pages.Speed.Icon, Theme.Pages.Speed.Color, Theme.Pages.Speed.Color2)
Pages.Win = Lib.CreatePage("Win", "الفوز", Theme.Pages.Win.Icon, Theme.Pages.Win.Color, Theme.Pages.Win.Color2)
Pages.Economy = Lib.CreatePage("Economy", "الاقتصاد", Theme.Pages.Economy.Icon, Theme.Pages.Economy.Color, Theme.Pages.Economy.Color2)
Pages.Movement = Lib.CreatePage("Movement", "الحركة", Theme.Pages.Movement.Icon, Theme.Pages.Movement.Color, Theme.Pages.Movement.Color2)
Pages.Visuals = Lib.CreatePage("Visuals", "المرئيات", Theme.Pages.Visuals.Icon, Theme.Pages.Visuals.Color, Theme.Pages.Visuals.Color2)
Pages.Gravity = Lib.CreatePage("Gravity", "الجاذبية", Theme.Pages.Gravity.Icon, Theme.Pages.Gravity.Color, Theme.Pages.Gravity.Color2)
Pages.Settings = Lib.CreatePage("Settings", "الإعدادات", Theme.Pages.Settings.Icon, Theme.Pages.Settings.Color, Theme.Pages.Settings.Color2)

-- ==========================================================
-- 🏠 الرئيسية
-- ==========================================================
do
    local page = Pages.Home
    page.AddHeader("SpeedPlus", "ماب الحلوى والشوكولاتة — تحكم كامل")

    page.AddSection("حالة اللاعب (مباشر)")

    local statLabels = {}
    for _, statName in ipairs(Config.StatNames) do
        local label = page.AddLabel("  ⏳ " .. statName .. ": جاري القراءة...")
        table.insert(statLabels, { name = statName, label = label })
    end

    -- قراءة الإحصائيات كل ثانية
    task.spawn(function()
        while Lib.ScreenGui.Parent do
            task.wait(1)
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            for _, item in ipairs(statLabels) do
                local stat = ls and ls:FindFirstChild(item.name)
                if stat then
                    item.label.Text = "  ✅ " .. item.name .. ": " .. Utils.FormatNumber(stat.Value)
                    item.label.TextColor3 = Theme.Mint
                else
                    item.label.TextColor3 = Theme.SubText
                    item.label.Text = "  ⚠️ " .. item.name .. ": غير متوفر"
                end
            end
        end
    end)

    page.AddSection("سريع")
    page.AddToggle({ icon = "💜", title = "هالة الشخصية", desc = "توهج قوس قزح نابض حولك", default = false,
        callback = function(v)
            if SP.Aura then SP.Aura.SetCharacterAura(v) end
        end })
    page.AddToggle({ icon = "✨", title = "الخلفية المتحركة", desc = "فقاعات + جزيئات + نجوم", default = true,
        callback = function(v)
            if SP.Background then SP.Background.SetEnabled(v) end
        end })
    page.AddToggle({ icon = "📊", title = "شريط الحالة (HUD)", desc = "إحصائياتك فوق الشاشة", default = true,
        callback = function(v)
            if SP.HUD then SP.HUD.SetVisible(v) end
        end })
end

-- ==========================================================
-- ⚙️ الإعدادات
-- ==========================================================
do
    local page = Pages.Settings
    page.AddHeader("الإعدادات", "إدارة الواجهة والمشروع")

    page.AddSection("حول")
    page.AddLabel("SpeedPlus v" .. Config.Version .. " — للاستخدام الشخصي")
    page.AddLabel("اللعبة: +1 Speed Keyboard Escape (Place 95082159892680)")
    page.AddLabel("عدد الوحدات: " .. #Config.Modules)

    page.AddSection("تحكم")
    page.AddButton({ icon = "💥", title = "إغلاق الواجهة نهائياً", color = Theme.Danger,
        callback = function()
            Utils.Shutdown()
            Utils.Notify("SpeedPlus", "تم إيقاف كل الميزات")
            task.wait(0.6)
            if SP.Lib then SP.Lib.ScreenGui:Destroy() end
        end })
end

SP.PagesRef = Pages
