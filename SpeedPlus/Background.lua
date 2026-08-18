--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 6) Background — خلفية أنميشن متحركة
  فقاعات طايفة + جزيئات حلوى + نجوم متلألئة
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Lib = SP.Lib
local Theme = SP.Theme
local Utils = SP.Utils
local New = Utils.New
local TweenService = game:GetService("TweenService")

local Bg = {}
local Enabled = true
local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera or Camera
end)

-- 1) الفقاعات الملونة الطايفة
local Blobs = {}
for i = 1, 5 do
    local sizes = { 150, 220, 280 }
    local size = sizes[i % 3 + 1]
    local blob = New("Frame", {
        Name = "Blob" .. i,
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = Theme.Palette[i % #Theme.Palette + 1],
        BackgroundTransparency = 0.9,
        ZIndex = 1,
    }, Lib.BgLayer)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, blob)
    blob.Position = UDim2.new(0, math.random(-60, 400), 0, math.random(-60, 460))
    table.insert(Blobs, blob)

    task.spawn(function()
        while Lib.ScreenGui.Parent do
            local target = UDim2.new(0, math.random(-80, 460), 0, math.random(-80, 500))
            local tween = TweenService:Create(blob,
                TweenInfo.new(math.random(7, 12), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { Position = target })
            tween:Play()
            tween.Completed:Wait()
            task.wait(math.random(1, 3))
        end
    end)
end

-- 2) جزيئات الحلوى الصاعدة
local Particles = {}
for i = 1, 12 do
    local part = New("Frame", {
        Name = "Candy",
        Size = UDim2.fromOffset(math.random(6, 16), math.random(6, 16)),
        BackgroundColor3 = Theme.Palette[math.random(#Theme.Palette)],
        BackgroundTransparency = 0.2,
        ZIndex = 1,
    }, Lib.BgLayer)
    New("UICorner", { CornerRadius = UDim.new(0.35, 0) }, part)
    table.insert(Particles, part)

    task.spawn(function()
        task.wait(math.random(0, 8))
        while Lib.ScreenGui.Parent do
            if not Enabled then
                task.wait(1)
            else
                local vp = Camera.ViewportSize
                local x0 = math.random(0, vp.X)
                part.Position = UDim2.new(0, x0, 0, vp.Y + 20)
                part.Rotation = math.random(0, 360)
                local rise = TweenService:Create(part, TweenInfo.new(math.random(6, 13), Enum.EasingStyle.Linear), {
                    Position = UDim2.new(0, x0 + math.random(-40, 40), 0, -30),
                    Rotation = part.Rotation + math.random(90, 360),
                })
                rise:Play()
                rise.Completed:Wait()
            end
        end
    end)
end

-- 3) النجوم المتلألئة (لمسة فضاء)
local Stars = {}
for i = 1, 18 do
    local star = New("Frame", {
        Name = "Star",
        Size = UDim2.fromOffset(math.random(2, 4), math.random(2, 4)),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.4,
        ZIndex = 1,
    }, Lib.BgLayer)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, star)
    star.Position = UDim2.new(0, math.random(0, 400), 0, math.random(0, 500))
    table.insert(Stars, star)

    task.spawn(function()
        while Lib.ScreenGui.Parent do
            local twinkle = TweenService:Create(star, TweenInfo.new(math.random(1, 3), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = math.random(0, 70) / 100,
            })
            twinkle:Play()
            twinkle.Completed:Wait()
        end
    end)
end

function Bg.SetEnabled(enabled)
    Enabled = enabled
    for _, blob in ipairs(Blobs) do blob.Visible = enabled end
    for _, star in ipairs(Stars) do star.Visible = enabled end
    -- الجزيئات تُدار ذاتياً داخل حلقتها
end

SP.Background = Bg
