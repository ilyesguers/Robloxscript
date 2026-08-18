--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 10) Win — محرك الفوز الأسطوري
  - كشف لوحات الفوز (الاسم + اللون الأصفر) مع تخزين مؤقت
  - الوضع 1: انزلاق سماوي (صعود → انزلاق → هبوط) — يكسر الـ anti-cheat
  - الوضع 2: نقل فوري
  - الوضع 3: مشي ذكي
  - موت ذاتي لإعادة التوليد + ترويسة مضادة للفلاغ
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
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local page = SP.Pages.Win

local Win = { Enabled = false, Mode = "انزلاق سماوي", WinsDone = 0 }
local ModeValues = { "انزلاق سماوي", "نقل فوري", "مشي ذكي" }

-- إعدادات قابلة للضبط
local RiseHeight = Config.Win.RiseHeight
local Throttle = Config.Win.Throttle
local WinTarget = Config.Win.Target
local ResetAfter = Config.Win.ResetAfter
local Neutralize = false
local LastWins = nil

-- ==========================================================
-- كشف لوحات الفوز (مع تخزين مؤقت)
-- ==========================================================
local WinPads = {}
local LastScan = 0

local function ScanWinPads()
    if tick() - LastScan < 5 then return end
    LastScan = tick()
    local found = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local isPad = Utils.NameMatches(obj.Name, Config.WinKeywords)
            if not isPad and obj:IsA("Part") then
                pcall(function()
                    if obj.BrickColor.Name == "New Yeller" or obj.BrickColor.Name == "Bright yellow" then
                        isPad = true
                    end
                end)
            end
            if isPad then
                -- تحديث الموقع أو إضافته
                if not WinPads[obj] then
                    WinPads[obj] = true
                    found = found + 1
                end
            end
        end
    end
    return found
end

-- أقرب لوحة فوز
local function NearestWinPad()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for obj in pairs(WinPads) do
        if obj and obj.Parent then
            local dist = (obj.Position - root.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = obj
            end
        end
    end
    return best
end

-- الهدف النهائي (لوحة أو إحداثيات معروفة)
local function ResolveTarget()
    local pad = NearestWinPad()
    if pad then return pad.Position end
    return Config.KnownWinPos
end

-- ==========================================================
-- تحييد الفخاخ (وضع آمن)
-- ==========================================================
local function NeutralizeHazards()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if string.find(name, "kill", 1, true)
                or string.find(name, "lava", 1, true)
                or string.find(name, "chocolate", 1, true)
                or string.find(name, "liquid", 1, true) then
                obj.CanTouch = false
                obj.CanCollide = false
            end
        end
    end
end

-- ==========================================================
-- تنفيذ رحلة فوز واحدة
-- ==========================================================
local function DoWinCycle()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end

    local target = ResolveTarget()
    local start = root.CFrame

    -- تعطيل التصادم أثناء الرحلة (مؤقتاً)
    local restore = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.CanCollide then
                table.insert(restore, part)
                part.CanCollide = false
            end
        end
    end

    local ok = pcall(function()
        if Win.Mode == "انزلاق سماوي" then
            -- 1) صعود عمودي
            local riseEnd = start * CFrame.new(0, RiseHeight, 0)
            for i = 0, 1, 0.05 do
                if not Win.Enabled then return end
                root.CFrame = start:Lerp(riseEnd, i)
                task.wait(0.02)
            end
            -- 2) انزلاق أفقي
            local highTarget = Vector3.new(target.X, start.Y + RiseHeight, target.Z)
            local glideStart = riseEnd.Position
            for i = 0, 1, 0.03 do
                if not Win.Enabled then return end
                root.CFrame = CFrame.new(glideStart:Lerp(highTarget, i))
                task.wait(0.02)
            end
            -- 3) هبوط عمودي
            local landPos = target + Vector3.new(0, 3, 0)
            for i = 0, 1, 0.04 do
                if not Win.Enabled then return end
                root.CFrame = CFrame.new(highTarget:Lerp(landPos, i))
                task.wait(0.015)
            end
            root.CFrame = CFrame.new(landPos)
        elseif Win.Mode == "نقل فوري" then
            root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
        else -- مشي ذكي (سرعة طبيعية على الأرض)
            local dist = (target - root.Position).Magnitude
            local steps = math.max(8, math.floor(dist / 30))
            for i = 1, steps do
                if not Win.Enabled then return end
                root.CFrame = start:Lerp(CFrame.new(target + Vector3.new(0, 3, 0)), i / steps)
                task.wait(0.05)
            end
        end
    end)

    -- استعادة التصادم
    for _, part in ipairs(restore) do
        part.CanCollide = true
    end

    if not ok then return false end

    -- انتظار لمس اللوحة وتسجيل الفوز
    task.wait(1.5)

    -- موت ذاتي لإعادة التوليد (مثل السكربتات الشغالة)
    if ResetAfter and Win.Enabled then
        pcall(function()
            hum.Health = 0
        end)
    end
    return true
end

-- ==========================================================
-- حلقة الفوز
-- ==========================================================
local function Engine()
    while Win.Enabled do
        task.wait(0.5)
        pcall(function()
            ScanWinPads()
            if Neutralize then NeutralizeHazards() end

            -- فحص الهدف
            if WinTarget > 0 and Win.WinsDone >= WinTarget then
                Win.Enabled = false
                Utils.Notify("SpeedPlus 🏆", "تم تحقيق الهدف: " .. Win.WinsDone .. " فوز 🎉")
                return
            end

            -- مراقبة عدّاد الوِنس
            local now = Utils.GetStat("Wins")
            if now and LastWins and now > LastWins then
                Win.WinsDone = Win.WinsDone + 1
                Utils.Notify("SpeedPlus 🏆", "فوز #" .. Win.WinsDone .. " 🎉")
            end
            if now then LastWins = now end

            -- تنفيذ الرحلة
            if DoWinCycle() then
                task.wait(Throttle) -- ترويسة مضادة للفلاغ
            end
        end)
    end
end

function Win.IsActive()
    return Win.Enabled
end

-- زر فوز فوري (بدون التفعيل الدائم)
function Win.DoOnce()
    task.spawn(function()
        local ok = DoWinCycle()
        Utils.Notify("SpeedPlus 🏆", ok and "تم تنفيذ رحلة الفوز" or "فشلت الرحلة")
    end)
end

-- ==========================================================
-- بناء الواجهة
-- ==========================================================
page.AddHeader("محرك الفوز", "انزلاق سماوي إلى لوحة الفوز ✨")

page.AddSection("المحرك")
page.AddToggle({ icon = "🏆", title = "Auto Win", desc = "فوز تلقائي متكرر", default = false,
    callback = function(v)
        Win.Enabled = v
        if v then
            Win.WinsDone = 0
            LastWins = Utils.GetStat("Wins")
            task.spawn(Engine)
            Utils.Notify("SpeedPlus 🏆", "بدأ محرك الفوز — الوضع: " .. Win.Mode)
        else
            Utils.Notify("SpeedPlus 🏆", "تم إيقاف محرك الفوز")
        end
    end })

page.AddCycleButton({
    icon = "🛸", title = "أسلوب السفر", values = ModeValues, default = 1,
    callback = function(value)
        Win.Mode = value
    end,
})

page.AddButton({ icon = "⚡", title = "فوز فوري الآن", color = Theme.Yellow, pulse = true,
    callback = function()
        Win.DoOnce()
    end })

page.AddSection("ضبط")
page.AddSlider({ icon = "⬆️", title = "ارتفاع الصعود", min = 200, max = 1500, default = RiseHeight, suffix = "",
    callback = function(v) RiseHeight = v end })
page.AddSlider({ icon = "⏱️", title = "الترويسة (مضاد فلاغ)", min = 3, max = 30, default = Throttle, suffix = "ث",
    callback = function(v) Throttle = v end })
page.AddSlider({ icon = "🎯", title = "عدد الأهداف", min = 0, max = 100, default = WinTarget, suffix = "",
    desc = "0 = لا نهائي",
    callback = function(v) WinTarget = v end })

page.AddSection("أمان")
page.AddToggle({ icon = "🛡️", title = "الموت الذاتي بعد الفوز", desc = "إعادة توليد لتكرار الفوز", default = ResetAfter,
    callback = function(v) ResetAfter = v end })
page.AddToggle({ icon = "🧹", title = "تحييد الفخاخ", desc = "إلغاء مسببات الموت في الماب", default = false,
    callback = function(v) Neutralize = v end })

Utils.AddCleanup(function()
    Win.Enabled = false
end)

SP.Win = Win
