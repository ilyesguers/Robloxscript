--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 13) Visuals — محرك المرئيات
  ESP لوحات الفوز (توهج + تسميات) + ESP التريدميلات + ESP اللاعبين + إضاءة
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
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local page = SP.Pages.Visuals

local Vis = {
    WinESP = false,
    TreadmillESP = false,
    PlayerESP = false,
    Fullbright = false,
}

-- ==========================================================
-- ESP لوحات الفوز (توهج + اسم + مسافة)
-- ==========================================================
local WinTags = {}

local function RefreshWinESP()
    -- إزالة القديم
    for obj, tag in pairs(WinTags) do
        if not obj or not obj.Parent or not Vis.WinESP then
            pcall(function()
                if tag.Highlight then tag.Highlight:Destroy() end
                if tag.Billboard then tag.Billboard:Destroy() end
            end)
            WinTags[obj] = nil
        end
    end
    if not Vis.WinESP then return end

    -- إضافة الجديد
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local isPad = Utils.NameMatches(obj.Name, Config.WinKeywords)
            if not isPad and obj:IsA("Part") then
                pcall(function()
                    if obj.BrickColor.Name == "New Yeller" then isPad = true end
                end)
            end
            if isPad and not WinTags[obj] then
                local tag = {}
                tag.Highlight = Utils.New("Highlight", {
                    FillColor = Theme.Yellow, FillTransparency = 0.55,
                    OutlineColor = Theme.Gold, OutlineTransparency = 0,
                    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                    Parent = obj,
                })
                tag.Billboard = Utils.New("BillboardGui", {
                    Size = UDim2.fromOffset(120, 36), Adornee = obj,
                    AlwaysOnTop = true, MaxDistance = 600,
                }, obj)
                Utils.New("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                    Text = "🏆 WIN", TextColor3 = Theme.Yellow,
                    Font = Enum.Font.GothamBold, TextSize = 16,
                    TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0, 0, 0),
                }, tag.Billboard)
                WinTags[obj] = tag
            end
        end
    end
end

-- ==========================================================
-- ESP التريدميلات (ذهبي)
-- ==========================================================
local TmTags = {}

local function RefreshTreadmillESP()
    for obj, tag in pairs(TmTags) do
        if not obj or not obj.Parent or not Vis.TreadmillESP then
            pcall(function()
                if tag.Highlight then tag.Highlight:Destroy() end
                if tag.Billboard then tag.Billboard:Destroy() end
            end)
            TmTags[obj] = nil
        end
    end
    if not Vis.TreadmillESP then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character)
            and Utils.NameMatches(obj.Name, Config.TreadmillKeywords) then
            if not TmTags[obj] then
                local tag = {}
                tag.Highlight = Utils.New("Highlight", {
                    FillColor = Theme.Gold, FillTransparency = 0.6,
                    OutlineColor = Theme.Orange, OutlineTransparency = 0,
                    DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                    Parent = obj,
                })
                tag.Billboard = Utils.New("BillboardGui", {
                    Size = UDim2.fromOffset(120, 36), Adornee = obj,
                    AlwaysOnTop = true, MaxDistance = 500,
                }, obj)
                Utils.New("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                    Text = "🏃 تريدميل", TextColor3 = Theme.Gold,
                    Font = Enum.Font.GothamBold, TextSize = 14,
                    TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0, 0, 0),
                }, tag.Billboard)
                TmTags[obj] = tag
            end
        end
    end
end

-- ==========================================================
-- ESP اللاعبين (Chams + أسماء)
-- ==========================================================
local PlayerTags = {}
local PlayerConns = {}

local function TagPlayer(plr)
    if plr == LocalPlayer then return end
    local function OnChar(char)
        if not char then return end
        if PlayerTags[plr] then
            pcall(function()
                if PlayerTags[plr].Highlight then PlayerTags[plr].Highlight:Destroy() end
                if PlayerTags[plr].Billboard then PlayerTags[plr].Billboard:Destroy() end
            end)
            PlayerTags[plr] = nil
        end
        if not Vis.PlayerESP then return end
        local tag = {}
        tag.Highlight = Utils.New("Highlight", {
            FillColor = Theme.Pink, FillTransparency = 0.6,
            OutlineColor = Theme.Purple, OutlineTransparency = 0.1,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Parent = char,
        })
        local head = char:FindFirstChild("Head")
        if head then
            tag.Billboard = Utils.New("BillboardGui", {
                Size = UDim2.fromOffset(140, 40), Adornee = head,
                AlwaysOnTop = true, MaxDistance = 400,
            }, char)
            Utils.New("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Text = plr.Name, TextColor3 = Theme.Pink,
                Font = Enum.Font.GothamBold, TextSize = 13,
                TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0, 0, 0),
            }, tag.Billboard)
        end
        PlayerTags[plr] = tag
    end
    if plr.Character then OnChar(plr.Character) end
    if PlayerConns[plr] then PlayerConns[plr]:Disconnect() end
    PlayerConns[plr] = plr.CharacterAdded:Connect(OnChar)
end

local function RefreshPlayerESP()
    if Vis.PlayerESP then
        for _, plr in ipairs(Players:GetPlayers()) do
            TagPlayer(plr)
        end
        if not PlayerConns["_added"] then
            PlayerConns["_added"] = Players.PlayerAdded:Connect(TagPlayer)
        end
    else
        for plr, tag in pairs(PlayerTags) do
            pcall(function()
                if tag.Highlight then tag.Highlight:Destroy() end
                if tag.Billboard then tag.Billboard:Destroy() end
            end)
            PlayerTags[plr] = nil
        end
        if PlayerConns["_added"] then
            PlayerConns["_added"]:Disconnect()
            PlayerConns["_added"] = nil
        end
    end
end

-- ==========================================================
-- الإضاءة الكاملة
-- ==========================================================
local function SetFullbright(v)
    if v then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = Color3.new(0.4, 0.4, 0.4)
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.Brightness = 1
        Lighting.FogEnd = 100000
    end
end

-- حلقة تحديث ESP كل ثانيتين
task.spawn(function()
    while Lib.ScreenGui.Parent do
        task.wait(2)
        pcall(RefreshWinESP)
        pcall(RefreshTreadmillESP)
    end
end)

-- ==========================================================
-- بناء الواجهة
-- ==========================================================
page.AddHeader("المرئيات", "انظر كل شيء بعين الصقر 👁️")

page.AddSection("ESP الماب")
page.AddToggle({ icon = "🏆", title = "ESP لوحات الفوز", desc = "توهج أصفر + تسمية", default = false,
    callback = function(v)
        Vis.WinESP = v
        RefreshWinESP()
    end })
page.AddToggle({ icon = "🏃", title = "ESP التريدميلات", desc = "توهج ذهبي لأفضل تريدميل", default = false,
    callback = function(v)
        Vis.TreadmillESP = v
        RefreshTreadmillESP()
    end })

page.AddSection("ESP اللاعبين")
page.AddToggle({ icon = "👥", title = "ESP اللاعبين", desc = "توهج وردي + أسماء", default = false,
    callback = function(v)
        Vis.PlayerESP = v
        RefreshPlayerESP()
    end })

page.AddSection("الإضاءة")
page.AddToggle({ icon = "💡", title = "إضاءة كاملة", desc = "أضيء الخريطة كلها", default = false,
    callback = function(v)
        Vis.Fullbright = v
        SetFullbright(v)
    end })

Utils.AddCleanup(function()
    Vis.WinESP = false
    Vis.TreadmillESP = false
    Vis.PlayerESP = false
    if Vis.Fullbright then SetFullbright(false) end
    RefreshWinESP()
    RefreshTreadmillESP()
    RefreshPlayerESP()
end)

SP.Visuals = Vis
