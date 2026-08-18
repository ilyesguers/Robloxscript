--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 4) UI_Lib — مكتبة واجهة موبايل كاملة
  نافذة زجاجية + تبويبات ملونة + تحكمات متحركة (Toggle/Slider/Button/Cycle/TextBox)
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Theme = SP.Theme
local Utils = SP.Utils
local New = Utils.New
local CFG = SP.Config

-- تدمير نسخة سابقة
if CoreGui:FindFirstChild("SpeedPlusUI") then CoreGui.SpeedPlusUI:Destroy() end

-- ==========================================================
-- الجذر
-- ==========================================================
local ScreenGui = New("ScreenGui", {
    Name = "SpeedPlusUI", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, CoreGui)

local BgLayer = New("Frame", {
    Name = "BG", Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1, ZIndex = 1,
}, ScreenGui)

-- ==========================================================
-- النافذة
-- ==========================================================
local Window = New("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(CFG.WindowSize.X, CFG.WindowSize.Y),
    Position = UDim2.new(0.5, -CFG.WindowSize.X / 2, 0.5, -CFG.WindowSize.Y / 2),
    BackgroundColor3 = Theme.Glass, BackgroundTransparency = 0.05,
    BorderSizePixel = 0, Visible = false, ZIndex = 5,
}, ScreenGui)
New("UICorner", { CornerRadius = UDim.new(0, 16) }, Window)
local WindowStroke = New("UIStroke", {
    Color = Theme.Pink, Transparency = 0.3, Thickness = 1.6,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
}, Window)

-- توهج خلفي للنافذة
local WindowGlow = New("Frame", {
    Name = "Glow", Size = UDim2.new(1, 24, 1, 24),
    Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Theme.Pink, BackgroundTransparency = 0.92, ZIndex = 4,
}, ScreenGui)
New("UICorner", { CornerRadius = UDim.new(0, 24) }, WindowGlow)

-- ==========================================================
-- شريط العنوان
-- ==========================================================
local TopBar = New("Frame", {
    Name = "TopBar", Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Theme.Glass2, BackgroundTransparency = 0.1, ZIndex = 3,
}, Window)
New("UICorner", { CornerRadius = UDim.new(0, 16) }, TopBar)

New("TextLabel", {
    Name = "Title", Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 14, 0, 0),
    BackgroundTransparency = 1, Text = "  ⚡ " .. CFG.WindowName,
    TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4,
}, TopBar)

local VerChip = New("TextLabel", {
    Name = "Ver", Size = UDim2.fromOffset(46, 20), Position = UDim2.new(1, -88, 0, 14),
    BackgroundColor3 = Theme.Purple, BackgroundTransparency = 0.5,
    Text = "v" .. CFG.Version, TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 11, ZIndex = 4,
}, TopBar)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, VerChip)

local CloseBtn = New("TextButton", {
    Name = "Close", Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -40, 0, 8),
    BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0.15,
    Text = "✕", TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 15, ZIndex = 4,
}, TopBar)
New("UICorner", { CornerRadius = UDim.new(0, 10) }, CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)

-- ==========================================================
-- شريط التبويبات
-- ==========================================================
local TabBar = New("ScrollingFrame", {
    Name = "TabBar", Size = UDim2.new(1, 0, 0, 52), Position = UDim2.new(0, 0, 0, 48),
    BackgroundTransparency = 1, ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingDirection = Enum.ScrollingDirection.X, ZIndex = 3,
}, Window)

local TabIndicator = New("Frame", {
    Name = "Indicator", Size = UDim2.fromOffset(76, 3), Position = UDim2.new(0, 10, 1, -6),
    BackgroundColor3 = Theme.Pink, ZIndex = 4,
}, TabBar)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, TabIndicator)

-- ==========================================================
-- حاوية الصفحات
-- ==========================================================
local PageContainer = New("Frame", {
    Name = "Pages", Size = UDim2.new(1, -12, 1, -112), Position = UDim2.new(0, 6, 0, 106),
    BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2,
}, Window)

Utils.MakeDraggable(TopBar, Window)

-- ==========================================================
-- زر التشغيل العائم
-- ==========================================================
local ToggleBtn = New("TextButton", {
    Name = "SpeedPlusButton",
    Size = UDim2.fromOffset(CFG.ButtonSize, CFG.ButtonSize),
    Position = UDim2.new(0, 16, 1, -(CFG.ButtonSize + 20)),
    BackgroundColor3 = Theme.Glass2, Text = "⚡", TextColor3 = Theme.Gold,
    Font = Enum.Font.GothamBold, TextSize = 26, Visible = false, ZIndex = 6,
}, ScreenGui)
New("UICorner", { CornerRadius = UDim.new(1, 0) }, ToggleBtn)
New("UIStroke", { Color = Theme.Pink, Transparency = 0.2, Thickness = 2 }, ToggleBtn)
Utils.MakeDraggable(ToggleBtn, ToggleBtn)

-- كشف نقر ذكي (نقرة vs سحب)
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
-- المكتبة
-- ==========================================================
SP.Pages = SP.Pages or {}  -- صفحات كل وحدة ميزة (تُملأ في CreatePage)
local Lib = {
    ScreenGui = ScreenGui, BgLayer = BgLayer, Window = Window,
    TopBar = TopBar, TabBar = TabBar, PageContainer = PageContainer,
    ToggleBtn = ToggleBtn, WindowStroke = WindowStroke,
    Pages = {}, ActivePage = nil,
}

function Lib.SwitchTo(entry)
    if not entry then return end
    local prev = Lib.ActivePage
    if prev and prev.Page then
        prev.Page.Visible = false
        prev.Button.TextColor3 = Theme.SubText
    end
    entry.Page.Visible = true
    entry.Button.TextColor3 = Theme.Text
    Lib.ActivePage = entry

    -- تلوين المؤشر والإطار بلون الصفحة النشطة
    local pageColor = entry.Color or Theme.Pink
    TweenService:Create(TabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = pageColor,
    }):Play()
    TweenService:Create(WindowStroke, TweenInfo.new(0.25), { Color = pageColor }):Play()

    task.spawn(function()
        task.wait()
        if entry.Button.Parent then
            local absX = entry.Button.AbsolutePosition.X - TabBar.AbsolutePosition.X
            TweenService:Create(TabIndicator, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, absX + 8, 1, -6),
            }):Play()
        end
    end)
end

-- ==========================================================
-- إنشاء صفحة
-- ==========================================================
function Lib.CreatePage(key, displayName, icon, color, color2)
    color = color or Theme.Pink
    color2 = color2 or color

    local page = New("ScrollingFrame", {
        Name = "Page_" .. key,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3, ScrollBarImageColor3 = color,
        CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false,
    }, PageContainer)
    local layout = New("UIListLayout", {
        Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, page)
    New("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) }, page)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)

    -- زر التبويب
    local index = #Lib.Pages
    local btn = New("TextButton", {
        Name = "Tab_" .. key,
        Size = UDim2.fromOffset(92, 42), Position = UDim2.new(0, 4 + index * 100, 0, 5),
        BackgroundTransparency = 1,
        Text = icon .. " " .. displayName,
        TextColor3 = Theme.SubText, Font = Enum.Font.GothamBold, TextSize = 13,
        ZIndex = 4,
    }, TabBar)
    TabBar.CanvasSize = UDim2.new(0, 8 + (index + 1) * 100, 0, 0)

    local entry = {
        Page = page, Button = btn, Key = key,
        Name = displayName, Icon = icon, Color = color, Color2 = color2,
    }
    table.insert(Lib.Pages, entry)

    btn.MouseButton1Click:Connect(function() Lib.SwitchTo(entry) end)

    -- سحب أفقي للتبديل بين الصفحات
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

    -- ==========================================================
    -- واجهة الصفحة البرمجية
    -- ==========================================================
    local api = {}

    -- 🖼 لافتة رأس الصفحة (تدرج لوني + أيقونة)
    function api.AddHeader(title, subtitle)
        local banner = New("Frame", {
            Size = UDim2.new(1, -12, 0, 62), BackgroundTransparency = 0,
            BackgroundColor3 = color, ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 12) }, banner)
        local grad = New("UIGradient", {
            Color = ColorSequence.new(color, color2), Rotation = 60,
        }, banner)
        New("UIStroke", { Color = color2, Transparency = 0.45, Thickness = 1 }, banner)
        New("TextLabel", {
            Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 10, 0, 9),
            BackgroundTransparency = 1, Text = icon,
            Font = Enum.Font.GothamBold, TextSize = 30,
        }, banner)
        New("TextLabel", {
            Size = UDim2.new(1, -64, 0, 22), Position = UDim2.new(0, 62, 0, 10),
            BackgroundTransparency = 1, Text = title,
            TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, banner)
        New("TextLabel", {
            Size = UDim2.new(1, -64, 0, 18), Position = UDim2.new(0, 62, 0, 34),
            BackgroundTransparency = 1, Text = subtitle or "",
            TextColor3 = Color3.fromRGB(235, 235, 245),
            Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, banner)
        return banner
    end

    -- 📑 قسم
    function api.AddSection(title)
        local sec = New("Frame", {
            Size = UDim2.new(1, -12, 0, 30), BackgroundTransparency = 1,
        }, page)
        local inner = New("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, sec)
        local bar = New("Frame", {
            Size = UDim2.fromOffset(3, 16), Position = UDim2.new(0, 0, 0, 7),
            BackgroundColor3 = color,
        }, inner)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
        New("TextLabel", {
            Size = UDim2.new(1, -14, 1, 0), Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1, Text = title, TextColor3 = color2,
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, inner)
        return sec
    end

    -- 🏷 نص
    function api.AddLabel(text)
        return New("TextLabel", {
            Size = UDim2.new(1, -12, 0, 24),
            BackgroundTransparency = 1, Text = text,
            TextColor3 = Theme.SubText, Font = Enum.Font.Gotham, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, page)
    end

    -- 🔘 مفتاح تبديل (Toggle) — متحرك وملون بلون الصفحة
    function api.AddToggle(options)
        local row = New("Frame", {
            Size = UDim2.new(1, -12, 0, 56),
            BackgroundColor3 = Theme.Glass2, BackgroundTransparency = 0.3,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 12) }, row)
        New("UIStroke", {
            Color = color, Transparency = 0.85, Thickness = 1,
        }, row)

        New("TextLabel", {
            Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 14, 0, 7),
            BackgroundTransparency = 1,
            Text = (options.icon or "▪️") .. " " .. options.title,
            TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        New("TextLabel", {
            Size = UDim2.new(1, -80, 0, 16), Position = UDim2.new(0, 14, 0, 28),
            BackgroundTransparency = 1,
            Text = options.desc or "", TextColor3 = Theme.SubText,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local switch = New("Frame", {
            Name = "Switch", Size = UDim2.fromOffset(48, 26), Position = UDim2.new(1, -62, 0, 15),
            BackgroundColor3 = Color3.fromRGB(70, 62, 94), ZIndex = 3,
        }, row)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, switch)

        local knob = New("Frame", {
            Name = "Knob", Size = UDim2.fromOffset(20, 20), Position = UDim2.fromOffset(3, 3),
            BackgroundColor3 = Color3.fromRGB(205, 200, 225), ZIndex = 4,
        }, switch)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

        local state = options.default or false
        local function SetState(newState, silent)
            state = newState
            local targetX = state and (48 - 20 - 3) or 3
            TweenService:Create(knob, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(targetX, 3),
            }):Play()
            TweenService:Create(switch, TweenInfo.new(0.16), {
                BackgroundColor3 = state and color or Color3.fromRGB(70, 62, 94),
            }):Play()
            TweenService:Create(row:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.16), {
                Transparency = state and 0.25 or 0.85,
            }):Play()
            if not silent and options.callback then
                pcall(options.callback, state)
            end
        end

        -- طبقة لمس شفافة (موبايل)
        local overlay = New("TextButton", {
            Name = "TapLayer", Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1, AutoButtonColor = false,
            Text = "", ZIndex = 5,
        }, row)
        overlay.MouseButton1Click:Connect(function()
            SetState(not state)
        end)

        SetState(state, true)
        return row, function() return state end
    end

    -- 🎚 منزلق (Slider)
    function api.AddSlider(options)
        local min, max = options.min or 0, options.max or 100
        local value = options.default or min
        local suffix = options.suffix or ""

        local row = New("Frame", {
            Size = UDim2.new(1, -12, 0, 64),
            BackgroundColor3 = Theme.Glass2, BackgroundTransparency = 0.3,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 12) }, row)

        New("TextLabel", {
            Size = UDim2.new(1, -90, 0, 20), Position = UDim2.new(0, 14, 0, 6),
            BackgroundTransparency = 1,
            Text = (options.icon or "🎚️") .. " " .. options.title,
            TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local valueLabel = New("TextLabel", {
            Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(1, -90, 0, 6),
            BackgroundTransparency = 1,
            Text = tostring(value) .. suffix, TextColor3 = color2,
            Font = Enum.Font.GothamBold, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)

        local track = New("Frame", {
            Name = "Track", Size = UDim2.new(1, -28, 0, 8), Position = UDim2.new(0, 14, 0, 42),
            BackgroundColor3 = Color3.fromRGB(56, 50, 78), ZIndex = 3,
        }, row)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

        local fill = New("Frame", {
            Name = "Fill", Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = color, ZIndex = 4,
        }, track)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
        New("UIGradient", {
            Color = ColorSequence.new(color, color2), Rotation = 90,
        }, fill)

        local knob = New("Frame", {
            Name = "Knob", Size = UDim2.fromOffset(22, 22), Position = UDim2.new(0, -11, 0, -7),
            BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 5,
        }, track)
        New("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)
        New("UIStroke", { Color = color, Thickness = 2.5 }, knob)

        local dragging = false
        local function SetFromX(x)
            local absX, absW = track.AbsolutePosition.X, track.AbsoluteSize.X
            if absW <= 0 then return end
            local pct = math.clamp((x - absX) / absW, 0, 1)
            local rounded = math.floor(min + (max - min) * pct + 0.5)
            value = rounded
            fill.Size = UDim2.new(0, pct * absW, 1, 0)
            knob.Position = UDim2.new(0, pct * absW - 11, 0, -7)
            valueLabel.Text = tostring(rounded) .. suffix
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
        task.spawn(function()
            task.wait()
            if track.AbsoluteSize.X > 0 then
                SetFromX(track.AbsolutePosition.X + (value - min) / (max - min) * track.AbsoluteSize.X)
            end
        end)
        return row
    end

    -- 🔘 زر (بتدرج + توهج + حركة ضغط)
    function api.AddButton(options)
        local btn = New("TextButton", {
            Name = "ActionBtn",
            Size = UDim2.new(1, -12, 0, 46),
            BackgroundColor3 = color, BackgroundTransparency = 0.12,
            Text = (options.icon or "▶️") .. " " .. options.title,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextSize = 14,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 12) }, btn)
        New("UIGradient", { Color = ColorSequence.new(color, color2), Rotation = 75 }, btn)
        local stroke = New("UIStroke", {
            Color = color2, Transparency = 0.3, Thickness = 1.5,
        }, btn)

        btn.MouseButton1Click:Connect(function()
            -- أنيميشن ضغط نابض
            local s = TweenService:Create(btn, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -20, 0, 42), Position = UDim2.new(0, 8, 0, 2),
            })
            s:Play()
            s.Completed:Wait()
            local back = TweenService:Create(btn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -12, 0, 46), Position = UDim2.new(0, 6, 0, 0),
            })
            back:Play()
            if options.callback then pcall(options.callback) end
        end)

        -- نبض بطيء إذا طُلب
        if options.pulse then
            task.spawn(function()
                while btn.Parent and ScreenGui.Parent do
                    local up = TweenService:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        Transparency = 0.1,
                    })
                    up:Play()
                    up.Completed:Wait()
                    local down = TweenService:Create(stroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                        Transparency = 0.5,
                    })
                    down:Play()
                    down.Completed:Wait()
                end
            end)
        end
        return btn
    end

    -- 🔄 زر تدوير الخيارات (Cycle)
    function api.AddCycleButton(options)
        local values = options.values or {}
        local idx = options.default or 1
        local btn = New("TextButton", {
            Name = "CycleBtn",
            Size = UDim2.new(1, -12, 0, 46),
            BackgroundColor3 = Theme.Glass2, BackgroundTransparency = 0.2,
            Text = (options.icon or "🔄") .. " " .. options.title .. ": " .. tostring(values[idx]),
            TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 13,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 12) }, btn)
        New("UIStroke", { Color = color, Transparency = 0.4, Thickness = 1.5 }, btn)

        btn.MouseButton1Click:Connect(function()
            idx = idx % #values + 1
            btn.Text = (options.icon or "🔄") .. " " .. options.title .. ": " .. tostring(values[idx])
            -- وميض بلون الصفحة
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = color }):Play()
            task.delay(0.12, function()
                if btn.Parent then
                    TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Glass2 }):Play()
                end
            end)
            if options.callback then pcall(options.callback, values[idx], idx) end
        end)
        return btn, function() return values[idx], idx end
    end

    -- ⌨️ حقل إدخال نص
    function api.AddTextBox(options)
        local row = New("Frame", {
            Size = UDim2.new(1, -12, 0, 70),
            BackgroundColor3 = Theme.Glass2, BackgroundTransparency = 0.3,
            ZIndex = 2,
        }, page)
        New("UICorner", { CornerRadius = UDim.new(0, 12) }, row)

        New("TextLabel", {
            Size = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0, 12, 0, 6),
            BackgroundTransparency = 1,
            Text = (options.icon or "⌨️") .. " " .. options.title,
            TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)

        local box = New("TextBox", {
            Size = UDim2.new(1, -96, 0, 32), Position = UDim2.new(0, 12, 0, 28),
            BackgroundColor3 = Color3.fromRGB(20, 16, 34),
            PlaceholderText = options.placeholder or "...",
            PlaceholderColor3 = Theme.SubText,
            Text = "", TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham, TextSize = 13,
            ClearTextOnFocus = true, ZIndex = 3,
        }, row)
        New("UICorner", { CornerRadius = UDim.new(0, 8) }, box)
        New("UIStroke", { Color = color, Transparency = 0.5, Thickness = 1 }, box)

        local apply = New("TextButton", {
            Name = "Apply",
            Size = UDim2.fromOffset(72, 32), Position = UDim2.new(1, -84, 0, 28),
            BackgroundColor3 = color, Text = options.button or "تطبيق",
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 3,
        }, row)
        New("UICorner", { CornerRadius = UDim.new(0, 8) }, apply)
        apply.MouseButton1Click:Connect(function()
            if options.callback and #box.Text > 0 then
                pcall(options.callback, box.Text)
            end
        end)
        return box
    end

    SP.Pages[key] = api
    return api
end

SP.Lib = Lib
