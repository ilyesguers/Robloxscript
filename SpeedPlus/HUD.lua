--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 8) HUD — شريط الحالة الحي
  إحصائيات + أيقونات الميزات النشطة
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Lib = SP.Lib
local Theme = SP.Theme
local Utils = SP.Utils
local New = Utils.New
local Config = SP.Config
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HUD = {}

local Pill = New("Frame", {
    Name = "Hud",
    Size = UDim2.fromOffset(210, 36), Position = UDim2.new(0.5, -105, 0, 10),
    BackgroundColor3 = Theme.Glass, BackgroundTransparency = 0.12,
    ZIndex = 6,
}, Lib.ScreenGui)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, Pill)
New("UIStroke", { Color = Theme.Purple, Transparency = 0.4, Thickness = 1 }, Pill)

local PillText = New("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "⚡ -- | 🏆 -- | 🔄 --",
    TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12,
}, Pill)

task.spawn(function()
    while Lib.ScreenGui.Parent do
        task.wait(1)
        pcall(function()
            local speed = Utils.GetStat("Speed")
            local wins = Utils.GetStat("Wins")
            local rebirths = Utils.GetStat("Rebirths")
            local active = ""
            if SP.Farm and SP.Farm.IsActive() then active = active .. " ⚡" end
            if SP.Win and SP.Win.IsActive() then active = active .. " 🏆" end
            if SP.Gravity and SP.Gravity.IsActive() then active = active .. " 🌌" end
            PillText.Text = string.format("⚡ %s | 🏆 %s | 🔄 %s%s",
                speed and Utils.FormatNumber(speed) or "--",
                wins and Utils.FormatNumber(wins) or "--",
                rebirths and Utils.FormatNumber(rebirths) or "--",
                active)
        end)
    end
end)

function HUD.SetVisible(v)
    Pill.Visible = v
end

function HUD.SetText(t)
    PillText.Text = t
end

SP.HUD = HUD
