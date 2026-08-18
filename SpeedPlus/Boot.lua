--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 15) Boot — الإقلاع النهائي
  إظهار الزر + فتح الرئيسية + ترحيب
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Lib = SP.Lib
local Utils = SP.Utils
local TweenService = game:GetService("TweenService")
local Config = SP.Config

-- فتح الصفحة الرئيسية
Lib.SwitchTo(Lib.Pages[1])

-- إظهار الزر العائم بأنيميشن
task.spawn(function()
    task.wait(0.4)
    Lib.ToggleBtn.Visible = true
    TweenService:Create(Lib.ToggleBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(Config.ButtonSize, Config.ButtonSize),
    }):Play()
end)

Utils.Notify("SpeedPlus ⚡", "تم تحميل المشروع بنجاح (v" .. Config.Version .. ")")
print("[SpeedPlus] v" .. Config.Version .. " ready — جميع الوحدات محملة.")
