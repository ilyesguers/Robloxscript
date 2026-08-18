--[[
  ══════════════════════════════════════════════════════════════
  SpeedPlus v0.2 — أساس الواجهة (UI Foundation)
  اللعبة: +1 Speed Keyboard Escape | Candy & Chocolate
  المدعوم: Delta Executor — موبايل / كمبيوتر
  التشغيل:
      loadstring(game:HttpGet("https://raw.githubusercontent.com/ilyesguers/Robloxscript/main/SpeedPlus.lua"))()
  ──────────────────────────────────────────────────────────────
  المرحلة 1: واجهة جميلة + هالة + خلفية أنميشن متحركة
  المرحلة 2+: ربط الميزات (Speed Farm / Auto Win / اقتصاد / حركة)
  ══════════════════════════════════════════════════════════════
]]

-- ==========================================================
-- 0. إعدادات عامة (Config) — نقطة الصيانة الوحيدة
-- ==========================================================
local VERSION = "0.2"
local CONFIG = {
    WindowName = "SpeedPlus ⚡",
    WindowSize = Vector2.new(360, 500),
    ButtonSize = 60,
    StatNames = { "Speed", "Wins", "Rebirths" }, -- أسماء إحصائيات الـ leaderstats (تُقرأ بأمان)
}

-- ==========================================================
-- 1. الخدمات
-- ==========================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera or Camera
end)

-- تدمير نسخة سابقة إن وجدت
if CoreGui:FindFirstChild("SpeedPlusUI") then CoreGui.SpeedPlusUI:Destroy() end

-- ==========================================================
-- 2. الثيم (ألوان الحلوى والشوكولاتة)
-- ==========================================================
local Theme = {
    BG       = Color3.fromRGB(12, 9, 20),
    Glass    = Color3.fromRGB(26, 21, 40),
    Glass2   = Color3.fromRGB(38, 31, 58),
    Pink     = Color3.fromRGB(255, 110, 199),
    Mint     = Color3.fromRGB(77, 232, 180),
    Purple   = Color3.fromRGB(178, 107, 255),
    Gold     = Color3.fromRGB(255, 209, 102),
    Blue     = Color3.fromRGB(96, 165, 255),
    Text     = Color3.fromRGB(242, 240, 250),
    SubText  = Color3.fromRGB(166, 158, 190),
    Danger   = Color3.fromRGB(255, 92, 92),
}
Theme.Palette = { Theme.Pink, Theme.Mint, Theme.Purple, Theme.Gold, Theme.Blue }

-- ==========================================================
-- 3. أدوات مساعدة
-- ==========================================================

-- منشئ Instances سريع
local function New(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

-- إشعارات النظام
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3,
        })
    end)
end

-- سحب العناصر (يدعم الموبايل والكمبيوتر)
local function MakeDraggable(dragPart, movePart)
    local dragging, dragInput, startPos, startFrame
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            startPos = input.Position
            startFrame = movePart.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                end
            end)
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local vp = Camera.ViewportSize
            local w = movePart.AbsoluteSize.X
            local h = movePart.AbsoluteSize.Y
            if w <= 0 then w = 60 end
            if h <= 0 then h = 60 end
            local delta = dragInput.Position - startPos
            movePart.Position = UDim2.new(
                startFrame.X.Scale, math.clamp(startFrame.X.Offset + delta.X, 0, math.max(0, vp.X - w)),
                startFrame.Y.Scale, math.clamp(startFrame.Y.Offset + delta.Y, 0, math.max(0, vp.Y - h))
            )
        end
    end)
end

-- ==========================================================
-- 4. الشاشة الرئيسية + الخلفية المتحركة
-- ==========================================================
local ScreenGui = New("ScreenGui", {
    Name = "SpeedPlusUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, CoreGui)

local BackgroundLayer = New("Frame", {
    Name = "BG", Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1, ZIndex = 1,
}, ScreenGui)

local BgEnabled = true

-- 4.1 الفقاعات الملونة الطافية (Blobs)
local Blobs = {}
do
    local blobSizes = { 140, 200, 260 }
    for i = 1, 5 do
        local blob = New("Frame", {
            Name = "Blob" .. i,
            Size = UDim2.fromOffset(blobSizes[i % 3 + 1], blobSizes[i % 3 + 1]),
            BackgroundColor3 = Theme.Palette[i],
            BackgroundTransparency = 0.88,
            ZIndex = 1,
        }, BackgroundLayer)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, blob) -- شكل ناعم
        blob.Position = UDim2.new(0, math.random(-40, 340), 0, math.random(-40, 400))

        task.spawn(function()
            while ScreenGui.Parent do
                local target = UDim2.new(
                    0, math.random(-60, 420), 0, math.random(-60, 480)
                )
                local tween = TweenService:Create(blob,
                    TweenInfo.new(math.random(6, 11), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { Position = target })
                tween:Play()
                tween.Completed:Wait()
                task.wait(math.random(1, 3))
            end
        end)
        table.insert(Blobs, blob)
    end
end

-- 4.2 جزيئات الحلوى الطائرة (Particles) — بركة ثابتة تُعاد تدويرها
local Particles = {}
do
    for i = 1, 14 do
        local part = New("Frame", {
            Name = "Candy",
            Size = UDim2.fromOffset(math.random(6, 16), math.random(6, 16)),
            BackgroundColor3 = Theme.Palette[math.random(#Theme.Palette)],
            BackgroundTransparency = 0.25,
            ZIndex = 1,
        }, BackgroundLayer)
        New("UICorner", { CornerRadius = UDim.new(0.35, 0) }, part)
        table.insert(Particles, part)

        task.spawn(function()
            task.wait(math.random(0, 8)) -- انتشار عشوائي للبداية
            while ScreenGui.Parent do
                if not BgEnabled then
                    task.wait(1)
                else
                    local vp = Camera.ViewportSize
                    local x0 = math.random(0, vp.X)
                    local dur = math.random(6, 13)
                    part.Position = UDim2.new(0, x0, 0, vp.Y + 20)
                    part.Rotation = math.random(0, 360)
                    local rise = TweenService:Create(part, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
                        Position = UDim2.new(0, x0 + math.random(-40, 40), 0, -30),
                        Rotation = part.Rotation + math.random(90, 360),
                    })
                    rise:Play()
                    rise.Completed:Wait()
                end
            end
        end)
    end
end

local function SetBackgroundEnabled(enabled)
    BgEnabled = enabled
    for _, blob in ipairs(Blobs) do
        blob.Visible = enabled
    end
end

-- ==========================================================
-- 5. هالة نابضة (Pulsing Aura) حول عنصر
-- ==========================================================
local function AttachAuraRing(parent, color, radius)
    local ring = New("Frame", {
        Name = "AuraRing",
        Size = UDim2.fromOffset(radius, radius),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.85,
        ZIndex = math.max(0, parent.ZIndex - 1),
    }, parent)
    New("UICorner", { CornerRadius = UDim.new(1, 0) }, ring)

    task.spawn(function()
        while ring.Parent and ScreenGui.Parent do
            local goal = 1.25 + math.random() * 0.2
            local grow = TweenService:Create(ring, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.fromOffset(radius * goal, radius * goal),
                BackgroundTransparency = 0.5,
            })
            grow:Play()
            grow.Completed:Wait()
            local shrink = TweenService:Create(ring, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Size = UDim2.fromOffset(radius, radius),
                BackgroundTransparency = 0.85,
            })
            shrink:Play()
            shrink.Completed:Wait()
        end
    end)
    return ring
end

-- هالة الشخصية داخل اللعبة (Highlight نابض)
local CharAuraConnections = {}
local CharAuraEnabled = false

local function ApplyCharacterAura(character)
    if not character then return end
    local highlight = character:FindFirstChild("SpeedPlus_CharAura")
    if highlight then highlight:Destroy() end
    highlight = New("Highlight", {
        Name = "SpeedPlus_CharAura",
        FillColor = Theme.Pink,
        FillTransparency = 0.7,
        OutlineColor = Theme.Gold,
        OutlineTransparency = 0.15,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = character,
    })
    local startTime = tick()
    local conn = RunService.Heartbeat:Connect(function()
        if not CharAuraEnabled or not highlight.Parent then return end
        local t = (tick() - startTime) * 1.6
        highlight.FillTransparency = 0.62 + math.sin(t) * 0.14
        local idx = math.floor((t / (math.pi * 2)) % #Theme.Palette) + 1
        highlight.FillColor = Theme.Palette[idx]
    end)
    table.insert(CharAuraConnections, conn)
end

local function SetCharacterAura(enabled)
    CharAuraEnabled = enabled
    if not enabled then
        for _, conn in ipairs(CharAuraConnections) do
            pcall(function() conn:Disconnect() end)
        end
        table.clear(CharAuraConnections)
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChild("SpeedPlus_CharAura")
            if h then h:Destroy() end
        end
        return
    end
    ApplyCharacterAura(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    if CharAuraEnabled then ApplyCharacterAura(char) end
end)

-- ==========================================================
-- 6. مكتبة الواجهة (Lib)
-- ==========================================================
local Lib = {}
Lib.Pages = {}
Lib.ActivePage = nil

-- متغيرات يُعرّف بعضها لاحقاً (إعلان مسبق للمراجع)
local Window, TopBar, TabBar, TabIndicator, PageContainer, ToggleBtn, HudPill

-- النافذة الرئيسية
Window = New("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(CONFIG.WindowSize.X, CONFIG.WindowSize.Y),
    Position = UDim2.new(0.5, -CONFIG.WindowSize.X / 2, 0.5, -CONFIG.WindowSize.Y / 2),
    BackgroundColor3 = Theme.Glass,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 5,
}, ScreenGui)
New("UICorner", { CornerRadius = UDim.new(0, 14) }, Window)
New("UIStroke", {
    Color = Theme.Purple, Transparency = 0.35, Thickness = 1.5,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, Window)

-- توهج إطار النافذة (يتغير لونه باستمرار)
task.spawn(function()
    local stroke = Window:FindFirstChildOfClass("UIStroke")
    local i = 0
    while Window.Parent and ScreenGui.Parent do
        i = i + 1
        local tween = TweenService:Create(stroke, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Color = Theme.Palette[i % #Theme.Palette + 1], Transparency = 0.25,
        })
        tween:Play()
        tween.Completed:Wait()
    end
end)

-- شريط العنوان
TopBar = New("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Theme.Glass2,
    BackgroundTransparency = 0.15,
    ZIndex = 3,
}, Window)
New("UICorner", { CornerRadius = UDim.new(0, 14) }, TopBar)

New("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1,
    Text = " ⚡ " .. CONFIG.WindowName,
    TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4,
}, TopBar)

local CloseBtn = New("TextButton", {
    Name = "Close",
    Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -38, 0, 8),
    BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0.2,
    Text = "✕", TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 14,
    ZIndex = 4,
}, TopBar)
New("UICorner", { CornerRadius = UDim.new(0, 9) }, CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)

-- شريط التبويبات
TabBar = New("ScrollingFrame", {
    Name = "TabBar",
    Size = UDim2.new(1, 0, 0, 46), Position = UDim2.new(0, 0, 0, 46),
    BackgroundTransparency = 1, ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingDirection = Enum.ScrollingDirection.X,
    ZIndex = 3,
}, Window)

-- مؤشر التبويب النشط
TabIndicator = New("Frame", {
    Name = "Indicator",
    Size = UDim2.fromOffset(72, 3), Position = UDim2.new(0, 8, 1, -6),
    BackgroundColor3 = Theme.Pink, ZIndex = 4,
}, TabBar)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, TabIndicator)

-- حاوية الصفحات
PageContainer = New("Frame", {
    Name = "Pages",
    Size = UDim2.new(1, -12, 1, -100), Position = UDim2.new(0, 6, 0, 98),
    BackgroundTransparency = 1, ClipsDescendants = true,
    ZIndex = 2,
}, Window)

MakeDraggable(TopBar, Window)

-- ==========================================================
-- 7. مكونات التحكم (Controls)
-- ==========================================================

local function AutoCanvas(page, padding)
    padding = padding or 16
    local layout = page:FindFirstChildOfClass("UIListLayout")
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + padding)
    end)
end

-- إنشاء صفحة جديدة
function Lib.CreatePage(name, icon)
    local page = New("ScrollingFrame", {
        Name = "Page_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
    }, PageContainer)
    local layout = New("UIListLayout", {
        Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, page)
    New("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, page)
    AutoCanvas(page)

    -- زر التبويب
    local index = #Lib.Pages
    local btn = New("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.fromOffset(88, 38), Position = UDim2.new(0, 4 + index * 96, 0, 4),
        BackgroundTransparency = 1,
        Text = icon .. " " .. name,
        TextColor3 = Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 13,
        ZIndex = 4,
    }, TabBar)
    TabBar.CanvasSize = UDim2.new(0, 8 + (#Lib.Pages + 1) * 96, 0, 0)

    local entry = { Page = page, Button = btn, Name = name, Icon = icon }
    table.insert(Lib.Pages, entry)

    btn.MouseButton1Click:Connect(function()
        Lib.SwitchTo(entry)
    end)

    -- سحب أفقي لتبديل الصفحات (موبايل)
    local swipeX
    page.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            swipeX = input.Position.X
        end
    end)
    page.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and swipeX then
            local delta = input.Position.X - swipeX
            swipeX = nil
            local idx = table.find(Lib.Pages, entry)
            if idx then
                if delta > 60 and idx > 1 then
                    Lib.SwitchTo(Lib.Pages[idx - 1])
                elseif delta < -60 and idx < #Lib.Pages then
                    Lib.SwitchTo(Lib.Pages[idx + 1])
                end
            end
        end
    end)

    -- واجهة برمجية للصفحة
    local api = {}

    function api.AddSection(title)
        local sec = New("Frame", {
            Size = UDim2.new(1, -12, 0, 30), BackgroundTransparency = 1,
        }, page)
        -- إطار داخلي حتى لا يتداخل UIListLayout مع ترتيب العناصر
        local inner = New("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        }, sec)
        local bar = New("Frame", {
            Size = UDim2.fromOffset(3, 16), Position = UDim2.new(0, 0, 0, 7),
            BackgroundColor3 = Theme.Pink,
        }, inner)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
        New("TextLabel", {
            Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = title, TextColor3 = Theme.Gold,
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, inner)
        return sec
    end

    function api.AddLabel(text)
        return New("TextLabel", {
            Size = UDim2.new(1, -12, 0, 24),
            BackgroundTransparency = 1,
            Text = text, TextColor3 = Theme.SubText,
            Font = Enum.Font.Gotham, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, page)
    end

    function api.AddToggle(options)
        -- options: title, desc, default, callback(state)
        local row = New("Frame", {
            Size = UDim2.new(1, -12, 0, 54),
            BackgroundColor3 = Theme.Glass2, BackgroundTransparency = 0.35,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 10) }, row)

        New("TextLabel", {
            Size = UDim2.new(1, -76, 0, 20), Position = UDim2.new(0, 12, 0, 7),
            BackgroundTransparency = 1,
            Text = options.title, TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        New("TextLabel", {
            Size = UDim2.new(1, -76, 0, 16), Position = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            Text = options.desc or "", TextColor3 = Theme.SubText,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local switch = New("Frame", {
            Name = "Switch",
            Size = UDim2.fromOffset(46, 24), Position = UDim2.new(1, -58, 0, 15),
            BackgroundColor3 = Color3.fromRGB(70, 64, 92),
            ZIndex = 3,
        }, row)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, switch)

        local knob = New("Frame", {
            Name = "Knob",
            Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(3, 3),
            BackgroundColor3 = Color3.fromRGB(200, 196, 220),
            ZIndex = 4,
        }, switch)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

        local state = options.default or false
        local function SetState(newState, silent)
            state = newState
            local targetX = state and (46 - 18 - 3) or 3
            TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(targetX, 3),
            }):Play()
            TweenService:Create(switch, TweenInfo.new(0.16), {
                BackgroundColor3 = state and Theme.Mint or Color3.fromRGB(70, 64, 92),
            }):Play()
            if not silent and options.callback then
                pcall(options.callback, state)
            end
        end

        -- طبقة لمس شفافة فوق الصف:
        -- تعمل على الموبايل، وروبلكس يميّز داخلياً بين النقرة والسحب
        local overlay = New("TextButton", {
            Name = "TapLayer",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            AutoButtonColor = false,
            Text = "",
            ZIndex = 5,
        }, row)
        overlay.MouseButton1Click:Connect(function()
            SetState(not state)
        end)

        SetState(state, true) -- رسم الحالة الأولية بدون استدعاء
        return row, function() return state end
    end

    function api.AddSlider(options)
        -- options: title, min, max, default, suffix, callback(value)
        local min, max = options.min or 0, options.max or 100
        local value = options.default or min

        local row = New("Frame", {
            Size = UDim2.new(1, -12, 0, 62),
            BackgroundColor3 = Theme.Glass2, BackgroundTransparency = 0.35,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 10) }, row)

        New("TextLabel", {
            Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 12, 0, 6),
            BackgroundTransparency = 1,
            Text = options.title, TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local valueLabel = New("TextLabel", {
            Size = UDim2.new(0, 70, 0, 20), Position = UDim2.new(1, -80, 0, 6),
            BackgroundTransparency = 1,
            Text = tostring(value) .. (options.suffix or ""),
            TextColor3 = Theme.Gold, Font = Enum.Font.GothamBold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)

        local track = New("Frame", {
            Name = "Track",
            Size = UDim2.new(1, -28, 0, 6), Position = UDim2.new(0, 14, 0, 40),
            BackgroundColor3 = Color3.fromRGB(58, 52, 80),
            ZIndex = 3,
        }, row)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

        local fill = New("Frame", {
            Name = "Fill",
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.Mint,
            ZIndex = 4,
        }, track)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

        local knob = New("Frame", {
            Name = "Knob",
            Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, -10, 0, -7),
            BackgroundColor3 = Color3.new(1, 1, 1),
            ZIndex = 5,
        }, track)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)
        New("UIStroke", { Color = Theme.Mint, Thickness = 2 }, knob)

        local dragging = false
        local function SetFromX(x)
            local absX, absW = track.AbsolutePosition.X, track.AbsoluteSize.X
            if absW <= 0 then return end
            local pct = math.clamp((x - absX) / absW, 0, 1)
            local rounded = math.floor(min + (max - min) * pct + 0.5)
            value = rounded
            fill.Size = UDim2.new(0, pct * absW, 1, 0)
            knob.Position = UDim2.new(0, pct * absW - 10, 0, -7)
            valueLabel.Text = tostring(rounded) .. (options.suffix or "")
            if options.callback then pcall(options.callback, rounded) end
        end

        local function StartDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                SetFromX(input.Position.X)
            end
        end
        track.InputBegan:Connect(StartDrag)
        knob.InputBegan:Connect(StartDrag)
        UserInputService.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
                SetFromX(input.Position.X)
            end
        end)

        -- ضبط القيمة الافتراضية بعد أول فريم (بعد اكتمال الـ Layout)
        task.spawn(function()
            task.wait()
            if track.AbsoluteSize.X > 0 then
                SetFromX(track.AbsolutePosition.X + (value - min) / (max - min) * track.AbsoluteSize.X)
            end
        end)
        return row
    end

    function api.AddButton(options)
        -- options: title, color, callback
        local color = options.color or Theme.Purple
        local btn = New("TextButton", {
            Size = UDim2.new(1, -12, 0, 44),
            BackgroundColor3 = color, BackgroundTransparency = 0.25,
            Text = options.title,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextSize = 14,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 10) }, btn)
        New("UIStroke", { Color = color, Transparency = 0.4, Thickness = 1 }, btn)

        btn.MouseButton1Click:Connect(function()
            btn.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.3)
            task.delay(0.15, function()
                if btn.Parent then btn.BackgroundColor3 = color end
            end)
            if options.callback then pcall(options.callback) end
        end)
        return btn
    end

    return api
end

-- تبديل الصفحات مع أنيميشن
function Lib.SwitchTo(entry)
    local prev = Lib.ActivePage
    if prev and prev.Page then
        prev.Page.Visible = false
        prev.Button.TextColor3 = Theme.SubText
    end
    entry.Page.Visible = true
    entry.Button.TextColor3 = Theme.Text
    Lib.ActivePage = entry

    task.spawn(function()
        task.wait()
        local absX = entry.Button.AbsolutePosition.X - TabBar.AbsolutePosition.X
        TweenService:Create(TabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, absX + 8, 1, -6),
        }):Play()
    end)
end

-- ==========================================================
-- 8. زر التشغيل العائم (بهالة نابضة)
-- ==========================================================
ToggleBtn = New("TextButton", {
    Name = "SpeedPlusButton",
    Size = UDim2.fromOffset(CONFIG.ButtonSize, CONFIG.ButtonSize),
    Position = UDim2.new(0, 16, 1, -(CONFIG.ButtonSize + 20)),
    BackgroundColor3 = Theme.Glass2,
    Text = "⚡", TextColor3 = Theme.Gold,
    Font = Enum.Font.GothamBold, TextSize = 26,
    Visible = false,
    ZIndex = 6,
}, ScreenGui)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, ToggleBtn)
New("UIStroke", { Color = Theme.Pink, Transparency = 0.2, Thickness = 2 }, ToggleBtn)
AttachAuraRing(ToggleBtn, Theme.Pink, CONFIG.ButtonSize + 26)
MakeDraggable(ToggleBtn, ToggleBtn)

-- كشف نقر ذكي: يميّز بين النقرة والسحب (حتى لا تنفتح النافذة بعد سحب الزر)
local btnPressPos, btnPressTime
ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        btnPressPos = input.Position
        btnPressTime = tick()
    end
end)
ToggleBtn.InputEnded:Connect(function(input)
    if btnPressPos and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        local dist = (input.Position - btnPressPos).Magnitude
        local dur = tick() - (btnPressTime or 0)
        btnPressPos, btnPressTime = nil, nil
        if dist < 20 and dur < 0.6 then
            Window.Visible = not Window.Visible
        end
    end
end)

-- ==========================================================
-- 9. بناء الصفحات
-- ==========================================================

-- 🏠 الرئيسية
do
    local page = Lib.CreatePage("الرئيسية", "🏠")

    page.AddSection("حالة اللاعب (مباشر)")

    local statLabels = {}
    for _, statName in ipairs(CONFIG.StatNames) do
        local label = page.AddLabel("  " .. statName .. ": ⏳ جاري القراءة...")
        table.insert(statLabels, { name = statName, label = label })
    end

    -- قراءة الـ leaderstats بأمان كل ثانية
    task.spawn(function()
        while ScreenGui.Parent do
            task.wait(1)
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            for _, item in ipairs(statLabels) do
                local stat = ls and ls:FindFirstChild(item.name)
                if stat then
                    local val = tostring(stat.Value)
                    if #val > 7 then val = string.format("%.2fM", stat.Value / 1e6) end
                    item.label.Text = "  " .. item.name .. ": " .. val
                    item.label.TextColor3 = Theme.Mint
                else
                    item.label.TextColor3 = Theme.SubText
                    item.label.Text = "  " .. item.name .. ": غير متوفر"
                end
            end
        end
    end)

    page.AddSection("سريع")
    page.AddToggle({ title = "هالة الشخصية", desc = "توهج نابض حولك داخل اللعبة", default = false,
        callback = function(v) SetCharacterAura(v) end })
    page.AddToggle({ title = "الخلفية المتحركة", desc = "فقاعات + جزيئات حلوى", default = true,
        callback = function(v) SetBackgroundEnabled(v) end })
    page.AddToggle({ title = "شريط الحالة (HUD)", desc = "سرعتك ووِنسك فوق الشاشة", default = true,
        callback = function(v) if HudPill then HudPill.Visible = v end end })
end

-- ⚡ السرعة (الميزات تُربط في المرحلة 2)
do
    local page = Lib.CreatePage("السرعة", "⚡")
    page.AddSection("Auto Speed Farm")
    page.AddLabel("سيتم ربط محرك التريدميل ومحاكاة الكيبورد هنا.")
    page.AddToggle({ title = "Auto Farm", desc = "زراعة السرعة تلقائياً", default = false,
        callback = function(v) Notify("SpeedPlus", v and "🔜 قريباً في التحديث القادم" or "تم الإيقاف") end })
    page.AddSlider({ title = "سرعة المحاكاة", min = 1, max = 10, default = 5, suffix = "x",
        callback = function() end })
end

-- 🏆 الفوز
do
    local page = Lib.CreatePage("الفوز", "🏆")
    page.AddSection("Auto Win")
    page.AddLabel("كشف لوحة الفوز الصفراء + نقل سلس + ترويسة.")
    page.AddToggle({ title = "Auto Win", desc = "التوجه لمنصة النهاية تلقائياً", default = false,
        callback = function(v) Notify("SpeedPlus", v and "🔜 قريباً في التحديث القادم" or "تم الإيقاف") end })
    page.AddSlider({ title = "عدد الأهداف", min = 1, max = 50, default = 10, suffix = "",
        callback = function() end })
end

-- 💰 الاقتصاد
do
    local page = Lib.CreatePage("الاقتصاد", "💰")
    page.AddSection("اقتصاد اللعبة")
    page.AddLabel("Rebirth / هدايا / كوبونات — تُربط في المرحلة 2.")
    page.AddToggle({ title = "Auto Rebirth", desc = "ريبيرث عند بلوغ الشرط", default = false,
        callback = function(v) Notify("SpeedPlus", v and "🔜 قريباً في التحديث القادم" or "تم الإيقاف") end })
    page.AddButton({ title = "🎁 استلام الهدية اليومية", color = Theme.Gold,
        callback = function() Notify("SpeedPlus", "🔜 قريباً في التحديث القادم") end })
end

-- 🦶 الحركة
do
    local page = Lib.CreatePage("الحركة", "🦶")
    page.AddSection("الحركة")

    -- WalkSpeed يعمل فعلياً الآن (خاصية عميل)
    local WalkSpeedValue = 16
    page.AddSlider({ title = "سرعة المشي (WalkSpeed)", min = 16, max = 120, default = 16, suffix = "",
        callback = function(v)
            WalkSpeedValue = v
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end })

    -- إعادة تطبيق الـ WalkSpeed عند الموت
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = WalkSpeedValue end
    end)

    page.AddToggle({ title = "قفزة لا نهائية", desc = "قريباً", default = false,
        callback = function(v) Notify("SpeedPlus", "🔜 قريباً في التحديث القادم") end })
    page.AddToggle({ title = "Noclip", desc = "قريباً", default = false,
        callback = function(v) Notify("SpeedPlus", "🔜 قريباً في التحديث القادم") end })
    page.AddToggle({ title = "طيران", desc = "قريباً", default = false,
        callback = function(v) Notify("SpeedPlus", "🔜 قريباً في التحديث القادم") end })
end

-- 👁 المرئيات
do
    local page = Lib.CreatePage("المرئيات", "👁")
    page.AddSection("المرئيات")
    page.AddLabel("ESP للوحات الفوز والتريدميلات — يُربط في المرحلة 2.")
    page.AddToggle({ title = "ESP لوحات الفوز", desc = "إظهار منصات الـ Win", default = false,
        callback = function(v) Notify("SpeedPlus", "🔜 قريباً في التحديث القادم") end })
    page.AddToggle({ title = "ESP التريدميلات", desc = "إظهار أفضل تريدميل", default = false,
        callback = function(v) Notify("SpeedPlus", "🔜 قريباً في التحديث القادم") end })
end

-- ⚙️ الإعدادات
do
    local page = Lib.CreatePage("الإعدادات", "⚙️")
    page.AddSection("الإعدادات")
    page.AddLabel("SpeedPlus v" .. VERSION .. " — مخصص لـ +1 Speed Keyboard Escape")
    page.AddLabel("للاستخدام الشخصي فقط 💜")
    page.AddButton({ title = "💥 إغلاق الواجهة", color = Theme.Danger,
        callback = function()
            Notify("SpeedPlus", "تم إغلاق الواجهة")
            task.wait(0.6)
            ScreenGui:Destroy()
        end })
end

-- ==========================================================
-- 10. شريط الحالة (HUD)
-- ==========================================================
HudPill = New("Frame", {
    Name = "Hud",
    Size = UDim2.fromOffset(200, 34), Position = UDim2.new(0.5, -100, 0, 10),
    BackgroundColor3 = Theme.Glass, BackgroundTransparency = 0.15,
    ZIndex = 6,
}, ScreenGui)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, HudPill)
New("UIStroke", { Color = Theme.Purple, Transparency = 0.4, Thickness = 1 }, HudPill)

local HudText = New("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "⚡ -- | 🏆 -- | 🔄 --",
    TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12,
}, HudPill)

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        pcall(function()
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            local speed = ls and ls:FindFirstChild("Speed")
            local wins = ls and ls:FindFirstChild("Wins")
            local rebirths = ls and ls:FindFirstChild("Rebirths")
            HudText.Text = string.format("⚡ %s | 🏆 %s | 🔄 %s",
                speed and tostring(speed.Value) or "--",
                wins and tostring(wins.Value) or "--",
                rebirths and tostring(rebirths.Value) or "--")
        end)
    end
end)

-- ==========================================================
-- 11. الإقلاع
-- ==========================================================
task.spawn(function()
    task.wait(0.4)
    ToggleBtn.Visible = true
    -- أنيميشن ظهور الزر
    TweenService:Create(ToggleBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(CONFIG.ButtonSize, CONFIG.ButtonSize),
    }):Play()
end)

-- فتح أول صفحة
Lib.SwitchTo(Lib.Pages[1])

Notify("SpeedPlus ⚡", "تم تحميل الواجهة بنجاح (v" .. VERSION .. ")")
print("SpeedPlus v" .. VERSION .. " loaded — UI Foundation Ready.")
