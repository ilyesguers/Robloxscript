--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 1) Config — إعدادات المشروع (نقطة الصيانة الوحيدة)
  اللعبة: +1 Speed Keyboard Escape | Candy & Chocolate
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

SP.Config = {
    Version   = "0.5",
    WindowName = "SpeedPlus",

    -- ملاحظة: المشروع دُمج في main ✅ (2026-08-18) — التعاون مستمر على الفرع

    -- هوية اللعبة المستهدفة (للتحقق من التوافق)
    GameId    = 9584852943,  -- Universe ID (game.GameId)
    PlaceId   = 95082159892680, -- Place ID

    -- رابط المشروع على GitHub (يستخدمه اللودر)
    BaseUrl   = "https://raw.githubusercontent.com/ilyesguers/Robloxscript/main/SpeedPlus/",
    Modules   = {
        "Config", "Theme", "Utils", "UI_Lib", "Pages",
        "Background", "Aura", "HUD",
        "Farm", "Win", "Economy", "Movement", "Visuals", "Gravity",
        "Boot",
    },

    WindowSize = Vector2.new(380, 545),
    ButtonSize = 60,

    -- أسماء الإحصائيات في الـ leaderstats
    StatNames = { "Speed", "Wins", "Rebirths" },

    -- أسماء الريمونات (تُحدَّث عند تغيير اللعبة)
    Remotes = {
        Rebirth     = "Rebirth",
        ClaimGift   = "ClaimGift",
        UpdateSpeed = "UpdateSpeed",
        CodeNames   = { "Code", "RedeemCode", "SubmitCode", "ClaimCode", "SocialCode" },
    },

    -- الكوبونات النشطة (أغسطس 2026)
    Codes = { "BYP4SS1", "BBNOWORLD", "BIGCONCERT" },

    -- كلمات البحث عن عناصر الماب
    WinKeywords      = { "win", "end", "goal", "finish", "exit", "pad", "portal" },
    TreadmillKeywords= { "treadmill", "tread", "runner", "mill", "walk" },
    DropKeywords     = { "egg", "coin", "candy", "orb", "gem", "drop", "token" },

    -- إحداثيات لوحة فوز معروفة (مرجع احتياطي — من سكربت givedebt)
    KnownWinPos = Vector3.new(-6809.3223, 531.2539, 1468.8073),

    -- إعدادات محرك الفوز الافتراضية
    Win = {
        RiseHeight = 900,   -- ارتفاع الصعود قبل الانزلاق
        Throttle   = 8,     -- ثوانٍ بين المحاولات (مضاد للفلاغ)
        Target     = 0,     -- 0 = لا نهائي
        ResetAfter = true,  -- موت ذاتي لإعادة التوليد
    },

    -- إعدادات الزراعة
    Farm = {
        MoveDelay  = 0.08,  -- ثوانٍ بين كل خطوة محاكاة
        Direction  = 2,     -- ثوانٍ قبل عكس الاتجاه
    },
}
