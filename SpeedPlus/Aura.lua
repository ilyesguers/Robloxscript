--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 7) Aura — الهالات النابضة
  حلقة توهج حول الزر العائم + هالة قوس قزح للشخصية
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
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Aura = {}

-- ==========================================================
-- حلقة نابضة حول عنصر
-- ==========================================================
function Aura.AttachRing(parent, color, radius)
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
        while ring.Parent and Lib.ScreenGui.Parent do
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

-- هالة الزر العائم
Aura.AttachRing(Lib.ToggleBtn, Theme.Pink, SP.Config.ButtonSize + 26)

-- ==========================================================
-- هالة الشخصية (قوس قزح نابض)
-- ==========================================================
local CharConnections = {}
local CharEnabled = false

local function ApplyCharacterAura(character)
    if not character then return end
    local highlight = character:FindFirstChild("SpeedPlus_CharAura")
    if highlight then highlight:Destroy() end
    highlight = New("Highlight", {
        Name = "SpeedPlus_CharAura",
        FillColor = Theme.Pink,
        FillTransparency = 0.68,
        OutlineColor = Theme.Gold,
        OutlineTransparency = 0.1,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = character,
    })
    local startTime = tick()
    local conn = RunService.Heartbeat:Connect(function()
        if not CharEnabled or not highlight.Parent then return end
        local t = (tick() - startTime) * 1.8
        highlight.FillTransparency = 0.6 + math.sin(t) * 0.15
        local idx = math.floor((t / (math.pi * 2)) % #Theme.Palette) + 1
        highlight.FillColor = Theme.Palette[idx]
        highlight.OutlineColor = Theme.Palette[(idx % #Theme.Palette) + 1]
    end)
    table.insert(CharConnections, conn)
end

function Aura.SetCharacterAura(enabled)
    CharEnabled = enabled
    if not enabled then
        for _, conn in ipairs(CharConnections) do
            pcall(function() conn:Disconnect() end)
        end
        CharConnections = {}
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
    if CharEnabled then ApplyCharacterAura(char) end
end)

Utils.AddCleanup(function()
    Aura.SetCharacterAura(false)
end)

SP.Aura = Aura
