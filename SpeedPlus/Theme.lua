--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 2) Theme — ألوان الحلوى + ألوان كل صفحة
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Theme = {
    BG      = Color3.fromRGB(10, 8, 18),
    Glass   = Color3.fromRGB(24, 20, 38),
    Glass2  = Color3.fromRGB(40, 33, 60),
    Text    = Color3.fromRGB(244, 242, 252),
    SubText = Color3.fromRGB(168, 160, 192),
    Danger  = Color3.fromRGB(255, 92, 92),

    Pink   = Color3.fromRGB(255, 110, 199),
    Mint   = Color3.fromRGB(77, 232, 180),
    Purple = Color3.fromRGB(178, 107, 255),
    Gold   = Color3.fromRGB(255, 209, 102),
    Blue   = Color3.fromRGB(96, 165, 255),
    Yellow = Color3.fromRGB(255, 210, 64),
    Orange = Color3.fromRGB(255, 150, 70),
    Cyan   = Color3.fromRGB(80, 220, 255),
    Deep   = Color3.fromRGB(70, 110, 255),
    Red    = Color3.fromRGB(255, 120, 120),
    Green  = Color3.fromRGB(120, 255, 160),
    Gray   = Color3.fromRGB(150, 150, 170),
}

Theme.Palette = { Theme.Pink, Theme.Mint, Theme.Purple, Theme.Gold, Theme.Blue, Theme.Cyan, Theme.Orange }

-- ألوان الصفحات: كل صفحة بلونها وأيقونتها الخاصة
Theme.Pages = {
    Home     = { Icon = "🏠", Color = Theme.Pink,   Color2 = Theme.Purple },
    Speed    = { Icon = "⚡", Color = Theme.Gold,   Color2 = Theme.Orange },
    Win      = { Icon = "🏆", Color = Theme.Yellow, Color2 = Theme.Gold },
    Economy  = { Icon = "💰", Color = Theme.Mint,   Color2 = Theme.Green },
    Movement = { Icon = "🦶", Color = Theme.Blue,   Color2 = Theme.Cyan },
    Visuals  = { Icon = "👁️", Color = Theme.Purple, Color2 = Theme.Pink },
    Gravity  = { Icon = "🌌", Color = Theme.Deep,   Color2 = Theme.Purple },
    Settings = { Icon = "⚙️", Color = Theme.Gray,   Color2 = Theme.Red },
}

SP.Theme = Theme
