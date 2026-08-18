--[[
  ══════════════════════════════════════════════════════════════
  SpeedPlus ⚡ — اللودر الرئيسي (استخرج هذا الملف فقط)
  اللعبة: +1 Speed Keyboard Escape | Candy & Chocolate
  المدعوم: Delta Executor — موبايل / كمبيوتر
  ──────────────────────────────────────────────────────────────
  التشغيل:
      loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/Robloxscript/main/SpeedPlus.lua"))()
  ──────────────────────────────────────────────────────────────
  هذا الملف يجلب وحدات المشروع من مجلد SpeedPlus/ ويشغّلها
  بالترتيب. أي وحدة تفشل لا توقف الباقي (تحميل مرن).
  ══════════════════════════════════════════════════════════════
]]

-- انتظار تحميل اللعبة
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

-- إعدادات اللودر (يمكن تعديلها هنا يدوياً)
-- يحاول تحميل الوحدات من عدة روابط بالترتيب (مرن تجاه الفروع)
SP.BaseUrls = SP.BaseUrls or {
    "https://raw.githubusercontent.com/ilyesguers/Robloxscript/main/SpeedPlus/",
    "https://raw.githubusercontent.com/ilyesguers/Robloxscript/arena/01a0156f-robloxscript/SpeedPlus/",
}
SP.Modules = SP.Modules or {
    "Config", "Theme", "Utils", "UI_Lib", "Pages",
    "Background", "Aura", "HUD",
    "Farm", "Win", "Economy", "Movement", "Visuals", "Gravity",
    "Boot",
}

local loadFn = loadstring or load

local function FetchModuleSource(name)
    -- جرّب كل الروابط حتى نجد الوحدة
    for _, base in ipairs(SP.BaseUrls) do
        local ok, src = pcall(function()
            return game:HttpGet(base .. name .. ".lua")
        end)
        if ok and src and #src > 0 then
            return src
        end
    end
    return nil
end

local loaded, failed = 0, {}

for _, moduleName in ipairs(SP.Modules) do
    local ok, err = pcall(function()
        local src = FetchModuleSource(moduleName)
        assert(src, "مصدر فارغ")
        local chunk = assert(loadFn(src), "صيغة Lua خاطئة")
        chunk()
    end)
    if ok then
        loaded = loaded + 1
    else
        table.insert(failed, moduleName .. " (" .. tostring(err) .. ")")
        warn("[SpeedPlus] فشل تحميل وحدة: " .. moduleName .. " — " .. tostring(err))
    end
end

print(string.format("[SpeedPlus] Loader: %d/%d وحدة تم تحميلها بنجاح.", loaded, #SP.Modules))

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SpeedPlus ⚡",
        Text = "تم تحميل " .. loaded .. "/" .. #SP.Modules .. " وحدة",
        Duration = 4,
    })
end)

if #failed > 0 then
    warn("[SpeedPlus] الوحدات الفاشلة: " .. table.concat(failed, " | "))
end
