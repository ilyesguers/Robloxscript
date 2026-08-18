--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 14) Gravity — وحدة الجاذبية الأسطورية 🌌
  - تحكم بالجاذبية (0 → عادية)
  - انعدام الجاذبية (Zero-G) — عوم كالفضاء
  - قفزة القمر — قفزات عملاقة
  - مغناطيس الفوز — جاذبية تسحبك للوحة الفوز
  - الثقب الأسود — يجذب كل الغنائم نحوك
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
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local page = SP.Pages.Gravity

local Grav = {
    ZeroG = false,
    Moon = false,
    Magnet = false,
    MagnetRadius = 600,
    Custom = false,
    CustomValue = 196.2,
}
local DEFAULT_GRAVITY = workspace.Gravity ~= 0 and workspace.Gravity or 196.2

local function SetGravity(v)
    pcall(function()
        workspace.Gravity = v
    end)
end

-- ==========================================================
-- انعدام الجاذبية (Zero-G)
-- ==========================================================
RunService.Stepped:Connect(function()
    if not Grav.ZeroG then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        -- منع السقوط الحر: حد أقصى للهبوط
        local vel = root.Velocity
        if vel.Y < -6 then
            root.Velocity = Vector3.new(vel.X, -6, vel.Z)
        end
    end
end)

-- ==========================================================
-- مغناطيس الفوز (جاذبية تسحبك للوحة)
-- ==========================================================
RunService.Heartbeat:Connect(function()
    if not Grav.Magnet then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- أقرب لوحة فوز (من كاش وحدة الفوز أو مسح سريع)
    local target = nil
    local bestDist = Grav.MagnetRadius
    if SP.Win then
        for obj in pairs(SP.Win.WinPads or {}) do
            if obj and obj.Parent then
                local d = (obj.Position - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    target = obj
                end
            end
        end
    end
    if not target then return end

    -- سحب جاذبي ناعم (كلما اقتربت زاد الجذب)
    local strength = 0.05 + 0.1 * (1 - bestDist / Grav.MagnetRadius)
    root.CFrame = root.CFrame:Lerp(CFrame.new(target.Position + Vector3.new(0, 3, 0)), strength)
end)

-- ==========================================================
-- الثقب الأسود: جذب الغنائم
-- ==========================================================
local function BlackHole()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local drops = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored
            and not obj:IsDescendantOf(LocalPlayer.Character)
            and Utils.NameMatches(obj.Name, Config.DropKeywords) then
            table.insert(drops, obj)
        end
    end
    if #drops == 0 then
        Utils.Notify("SpeedPlus 🌌", "لا توجد غنائم قريبة للجذب")
        return
    end

    Utils.Notify("SpeedPlus 🌌", "🕳️ الثقب الأسود يجذب " .. #drops .. " عنصر!")
    for _, drop in ipairs(drops) do
        if not drop or not drop.Parent then
            -- تجاهل العنصر المحذوف
        else
        local tween = TweenService:Create(drop, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            CFrame = root.CFrame * CFrame.new(0, 0, -3),
        })
        tween:Play()
        -- محاولة لمسها لجمعها
        pcall(function()
            if firetouchinterest then
                firetouchinterest(root, drop, 0)
                task.wait(0.05)
                firetouchinterest(root, drop, 1)
            end
        end)
        tween.Completed:Wait()
        end
    end
    Utils.Notify("SpeedPlus 🌌", "تم جذب " .. #drops .. " عنصر إليك 🎁")
end

-- ==========================================================
-- تطبيق الجاذبية حسب الحالة
-- ==========================================================
local function ApplyGravityState()
    if Grav.ZeroG then
        SetGravity(0)
    elseif Grav.Moon then
        SetGravity(35)
    elseif Grav.Custom then
        SetGravity(Grav.CustomValue)
    else
        SetGravity(DEFAULT_GRAVITY)
    end
end

-- قفزة القمر: قوة قفز عالية
local function ApplyMoonJump(v)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = v and 180 or 50
    end
end

-- ==========================================================
-- بناء الواجهة
-- ==========================================================
page.AddHeader("الجاذبية 🌌", "قوى كونية بين يديك")

page.AddSection("أوضاع الجاذبية")
page.AddToggle({ icon = "🪐", title = "انعدام الجاذبية (Zero-G)", desc = "عوم في الفضاء بلا سقوط", default = false,
    callback = function(v)
        Grav.ZeroG = v
        if v then Grav.Moon = false end
        ApplyGravityState()
    end })
page.AddToggle({ icon = "🌕", title = "قفزة القمر", desc = "قفزات عملاقة بجاذبية منخفضة", default = false,
    callback = function(v)
        Grav.Moon = v
        if v then Grav.ZeroG = false end
        ApplyGravityState()
        ApplyMoonJump(v)
    end })
page.AddToggle({ icon = "🎚️", title = "جاذبية مخصصة", desc = "اضبط قيمة الجاذبية يدوياً", default = false,
    callback = function(v)
        Grav.Custom = v
        ApplyGravityState()
    end })
page.AddSlider({ icon = "⚖️", title = "قيمة الجاذبية", min = 0, max = 200, default = 100, suffix = "",
    callback = function(v)
        Grav.CustomValue = v
        if Grav.Custom then ApplyGravityState() end
    end })

page.AddSection("قوى أسطورية")
page.AddToggle({ icon = "🧲", title = "مغناطيس الفوز", desc = "سحب جاذبي نحو لوحة الفوز", default = false,
    callback = function(v)
        Grav.Magnet = v
    end })
page.AddSlider({ icon = "📡", title = "نطاق المغناطيس", min = 100, max = 1200, default = 600, suffix = "",
    callback = function(v) Grav.MagnetRadius = v end })
page.AddButton({ icon = "🕳️", title = "الثقب الأسود — جذب الغنائم", color = Theme.Deep, pulse = true,
    callback = function()
        task.spawn(BlackHole)
    end })

page.AddSection("معلومات")
page.AddLabel("⚠️ أعد ضبط الجاذبية قبل دخول المراحل")

Utils.AddCleanup(function()
    Grav.ZeroG = false
    Grav.Moon = false
    Grav.Magnet = false
    Grav.Custom = false
    ApplyGravityState()
    ApplyMoonJump(false)
end)

function Grav.IsActive()
    return Grav.ZeroG or Grav.Moon or Grav.Magnet or Grav.Custom
end

SP.Gravity = Grav
