--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 11) Economy — محرك الاقتصاد
  Auto Rebirth + هدايا + كوبونات + إدخال كود مخصص
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local page = SP.Pages.Economy

local Economy = { Enabled = false, Threshold = 50000, LastRebirth = 0 }

-- ==========================================================
-- إيجاد الريمونات (مع تخزين مؤقت)
-- ==========================================================
local RemoteCache = {}
local function GetRemote(name)
    if RemoteCache[name] ~= nil then
        if RemoteCache[name] and RemoteCache[name].Parent then
            return RemoteCache[name]
        end
        RemoteCache[name] = nil
    end
    -- بحث مباشر بالاسم في ReplicatedStorage.Remotes
    local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
    local searchRoot = remotesFolder or ReplicatedStorage
    local found = searchRoot:FindFirstChild(name, true)
    if found and (found:IsA("RemoteEvent") or found:IsA("RemoteFunction")) then
        RemoteCache[name] = found
        return found
    end
    RemoteCache[name] = false
    return nil
end

-- ==========================================================
-- إجراءات
-- ==========================================================
local function ClaimGift()
    local remote = GetRemote(Config.Remotes.ClaimGift)
    if not remote then
        remote = Utils.FindRemote({ "claimgift", "gift", "daily" })
    end
    if remote then
        local ok = Utils.FireRemote(remote)
        Utils.Notify("SpeedPlus 💰", ok and "تم استلام الهدية 🎁" or "فشل استلام الهدية")
    else
        Utils.Notify("SpeedPlus 💰", "لم يتم العثور على ريمون الهدية")
    end
end

local function RedeemCode(code)
    if not code or #code == 0 then return end
    local remote = GetRemote("Code")
    if not remote then
        remote = Utils.FindRemote(Config.Remotes.CodeNames)
    end
    if remote then
        local ok, err = Utils.FireRemote(remote, code)
        Utils.Notify("SpeedPlus 💰", ok
            and ("تم إرسال الكود: " .. code)
            or ("فشل الكود: " .. tostring(err or "غير مقبول")))
    else
        Utils.Notify("SpeedPlus 💰", "لم يتم العثور على ريمون الكوبونات")
    end
end

local function DoRebirth()
    local remote = GetRemote(Config.Remotes.Rebirth)
    if not remote then
        remote = Utils.FindRemote({ "rebirth" })
    end
    if remote then
        local ok = Utils.FireRemote(remote)
        Utils.Notify("SpeedPlus 🔄", ok and "تم الريبيرث! مضاعف جديد 🎉" or "فشل الريبيرث")
        Economy.LastRebirth = tick()
    end
end

-- ==========================================================
-- حلقة الريبيرث التلقائي
-- ==========================================================
local function Engine()
    while Economy.Enabled do
        task.wait(2)
        pcall(function()
            local speed = Utils.GetStat("Speed")
            if speed and speed >= Economy.Threshold then
                if tick() - Economy.LastRebirth > 60 then
                    DoRebirth()
                end
            end
        end)
    end
end

function Economy.IsActive()
    return Economy.Enabled
end

-- ==========================================================
-- بناء الواجهة
-- ==========================================================
page.AddHeader("اقتصاد اللعبة", "ريبيرث + هدايا + كوبونات 💎")

page.AddSection("Auto Rebirth")
page.AddToggle({ icon = "🔄", title = "Auto Rebirth", desc = "ريبيرث عند بلوغ السرعة المطلوبة", default = false,
    callback = function(v)
        Economy.Enabled = v
        if v then
            task.spawn(Engine)
            Utils.Notify("SpeedPlus 🔄", "Auto Rebirth مفعل — العتبة: " .. Utils.FormatNumber(Economy.Threshold))
        end
    end })
page.AddSlider({ icon = "🎚️", title = "عتبة السرعة للريبيرث", min = 10, max = 1000, default = 50, suffix = "K",
    callback = function(v) Economy.Threshold = v * 1000 end })

page.AddSection("الهدايا والكوبونات")
page.AddButton({ icon = "🎁", title = "استلام الهدية اليومية", color = Theme.Mint,
    callback = ClaimGift })

-- أزرار الكوبونات المعروفة
for _, code in ipairs(Config.Codes) do
    page.AddButton({ icon = "🏷️", title = "كوبون: " .. code, color = Theme.Gold,
        callback = function()
            RedeemCode(code)
        end })
end

page.AddSection("كود مخصص")
page.AddTextBox({
    icon = "⌨️", title = "أدخل كود (من Discord أو التحديثات)",
    placeholder = "مثال: BYP4SS1", button = "استبدال",
    callback = function(text)
        RedeemCode(text)
    end,
})

Utils.AddCleanup(function()
    Economy.Enabled = false
end)

SP.Economy = Economy
