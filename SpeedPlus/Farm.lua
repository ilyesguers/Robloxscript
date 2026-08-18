--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 9) Farm — محرك زراعة السرعة
  الوضع 1: خطوات محاكاة (Humanoid:Move — لا يُكتشف، اللعبة تحسبها مشي حقيقي)
  الوضع 2: تريدميل (ينقلك لأفضل تريدميل ثم يمشي)
  الوضع 3: هجين (تريدميل إن وُجد، وإلا خطوات)
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
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local page = SP.Pages.Speed

local Farm = { Enabled = false, Mode = "خطوات", AntiAFK = true }
local ModeValues = { "خطوات (Move)", "تريدميل", "هجين" }

-- حالة
local walkDir = 1          -- اتجاه المشي الحالي
local lastDirChange = 0
local TreadmillCache = nil
local TreadmillScan = 0

-- البحث عن أفضل تريدميل (يُخزَّن مؤقتاً)
local function FindTreadmill()
    if TreadmillCache and TreadmillCache.Parent then return TreadmillCache end
    if tick() - TreadmillScan < 10 then return nil end
    TreadmillScan = tick()
    TreadmillCache = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and Utils.NameMatches(obj.Name, Config.TreadmillKeywords) then
            if not obj:IsDescendantOf(LocalPlayer.Character) then
                TreadmillCache = obj
                break
            end
        end
    end
    return TreadmillCache
end

-- خطوة مشي محاكاة
local function SimStep()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    -- عكس الاتجاه كل بضع ثوانٍ (حتى لا نصطدم بجدار)
    if tick() - lastDirChange > Config.Farm.Direction then
        lastDirChange = tick()
        walkDir = -walkDir
    end
    hum:Move(Vector3.new(0, 0, walkDir), true)
end

-- مضاد AFK
local function EnableAntiAFK()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        task.wait(0.1)
        pcall(function()
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end
EnableAntiAFK()

-- المحرك الرئيسي
local function Engine()
    while Farm.Enabled do
        task.wait(Config.Farm.MoveDelay)
        pcall(function()
            if Farm.Mode == "تريدميل" or Farm.Mode == "هجين" then
                local tm = FindTreadmill()
                if tm then
                    -- التأكد من الوقوف فوق التريدميل
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (root.Position - tm.Position).Magnitude
                        if dist > 12 then
                            root.CFrame = tm.CFrame * CFrame.new(0, 4, 0)
                            task.wait(0.5)
                        end
                    end
                    SimStep()
                    return
                elseif Farm.Mode == "تريدميل" then
                    Utils.Notify("SpeedPlus ⚡", "لا يوجد تريدميل قريب — جارٍ البحث...")
                    task.wait(5)
                    return
                end
            end
            -- الوضع الافتراضي: خطوات
            SimStep()
        end)
    end
end

function Farm.IsActive()
    return Farm.Enabled
end

-- ==========================================================
-- بناء الواجهة
-- ==========================================================
page.AddHeader("زراعة السرعة", "ابنِ سرعتك وأنت نايم 😴")

page.AddSection("المحرك")
page.AddToggle({ icon = "⚡", title = "Auto Farm", desc = "زراعة تلقائية للسرعة", default = false,
    callback = function(v)
        Farm.Enabled = v
        if v then
            task.spawn(Engine)
            Utils.Notify("SpeedPlus ⚡", "بدأت الزراعة — الوضع: " .. Farm.Mode)
        else
            Utils.Notify("SpeedPlus ⚡", "تم إيقاف الزراعة")
        end
    end })

page.AddCycleButton({
    icon = "🔄", title = "الوضع", values = ModeValues, default = 1,
    callback = function(value)
        Farm.Mode = value
        Utils.Notify("SpeedPlus ⚡", "وضع الزراعة: " .. value)
    end,
})

page.AddSection("ضبط")
page.AddSlider({ icon = "🐢", title = "سرعة الخطوات", min = 1, max = 10, default = 5, suffix = "x",
    callback = function(v)
        Config.Farm.MoveDelay = 0.4 / v
    end })
page.AddSlider({ icon = "↔️", title = "عكس الاتجاه كل", min = 1, max = 10, default = 2, suffix = "ث",
    callback = function(v)
        Config.Farm.Direction = v
    end })

page.AddSection("معلومات")
local infoLabel = page.AddLabel("  📈 سرعتك الحالية: --")

task.spawn(function()
    while Lib.ScreenGui.Parent do
        task.wait(1)
        local speed = Utils.GetStat("Speed")
        if speed then
            infoLabel.Text = "  📈 سرعتك الحالية: " .. Utils.FormatNumber(speed)
            infoLabel.TextColor3 = Farm.Enabled and Theme.Gold or Theme.SubText
        end
    end
end)

Utils.AddCleanup(function()
    Farm.Enabled = false
end)

SP.Farm = Farm
