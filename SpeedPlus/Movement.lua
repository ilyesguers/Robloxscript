--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 12) Movement — محرك الحركة
  WalkSpeed + JumpPower + قفزة لا نهائية + Noclip + طيران بأزرار موبايل
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Lib = SP.Lib
local Theme = SP.Theme
local Utils = SP.Utils
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local page = SP.Pages.Movement

local Move = {
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 300,
    FlyUp = false,   -- للأزرار اللمسية
    FlyDown = false,
    FlyFwd = true,
}

-- ==========================================================
-- حركة أساسية
-- ==========================================================
local function ApplyWalkSpeed()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Move.WalkSpeed end
end
local function ApplyJumpPower()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = Move.JumpPower
    end
end

-- قفزة لا نهائية
UserInputService.JumpRequest:Connect(function()
    if Move.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Noclip + الحفاظ على السرعة
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    if Move.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    if Move.WalkSpeed ~= 16 then ApplyWalkSpeed() end
end)

-- ==========================================================
-- الطيران (BodyGyro + BodyVelocity)
-- ==========================================================
local FlyBV, FlyBG, FlyConn

local function StartFly()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    StopFly()
    hum.PlatformStand = true

    FlyBG = Utils.New("BodyGyro", {
        MaxTorque = Vector3.new(9e9, 9e9, 9e9),
        P = 5e4,
        CFrame = root.CFrame,
    }, root)

    FlyBV = Utils.New("BodyVelocity", {
        MaxForce = Vector3.new(9e9, 9e9, 9e9),
        Velocity = Vector3.zero,
    }, root)

    FlyConn = RunService.RenderStepped:Connect(function()
        if not Move.Fly then return end
        local cam = workspace.CurrentCamera
        local spd = Move.FlySpeed
        local vel = Vector3.zero

        -- كمبيوتر: WASD + Space/Ctrl
        if UserInputService:IsKeyDown(Enum.KeyCode.W) or Move.FlyFwd then vel = vel + cam.CFrame.LookVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector * spd end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or Move.FlyUp then vel = vel + Vector3.new(0, spd, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Move.FlyDown then vel = vel - Vector3.new(0, spd, 0) end

        FlyBV.Velocity = vel
        FlyBG.CFrame = cam.CFrame
    end)
end

local function StopFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if FlyBG then FlyBG:Destroy() FlyBG = nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

-- أزرار الطيران اللمسية (موبايل)
local FlyButtons = {}
local function CreateFlyButtons()
    if #FlyButtons > 0 then return end
    local function MakeBtn(text, pos, flagName)
        local btn = Utils.New("TextButton", {
            Size = UDim2.fromOffset(64, 64),
            Position = pos,
            BackgroundColor3 = Theme.Blue, BackgroundTransparency = 0.3,
            Text = text, TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold, TextSize = 28,
            ZIndex = 7,
        }, Lib.ScreenGui)
        Utils.New("UICorner", { CornerRadius = UDim.new(1, 0) }, btn)
        Utils.New("UIStroke", { Color = Theme.Cyan, Transparency = 0.3, Thickness = 2 }, btn)
        local function Set(v)
            Move[flagName] = v
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundTransparency = v and 0.05 or 0.3,
            }):Play()
        end
        btn.MouseButton1Down:Connect(function() Set(true) end)
        btn.MouseButton1Up:Connect(function() Set(false) end)
        btn.MouseLeave:Connect(function() Set(false) end)
        table.insert(FlyButtons, btn)
    end
    MakeBtn("▲", UDim2.new(1, -150, 1, -190), "FlyUp")
    MakeBtn("▼", UDim2.new(1, -76, 1, -190), "FlyDown")
    MakeBtn("➤", UDim2.new(1, -150, 1, -110), "FlyFwd")
end
local function RemoveFlyButtons()
    for _, btn in ipairs(FlyButtons) do
        pcall(function() btn:Destroy() end)
    end
    FlyButtons = {}
end

-- إعادة التطبيق بعد الموت
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplyWalkSpeed()
    ApplyJumpPower()
    if Move.Fly then StartFly() end
end)

-- ==========================================================
-- بناء الواجهة
-- ==========================================================
page.AddHeader("محرك الحركة", "تحكم كامل بجسدك 🦶")

page.AddSection("سرعة وقفز")
page.AddSlider({ icon = "💨", title = "سرعة المشي", min = 16, max = 250, default = 16, suffix = "",
    callback = function(v)
        Move.WalkSpeed = v
        ApplyWalkSpeed()
    end })
page.AddSlider({ icon = "🦘", title = "قوة القفز", min = 50, max = 500, default = 50, suffix = "",
    callback = function(v)
        Move.JumpPower = v
        ApplyJumpPower()
    end })

page.AddSection("قدرات")
page.AddToggle({ icon = "🔄", title = "قفزة لا نهائية", desc = "اقفز في الهواء بلا حدود", default = false,
    callback = function(v) Move.InfJump = v end })
page.AddToggle({ icon = "👻", title = "Noclip", desc = "المرور عبر الجدران", default = false,
    callback = function(v) Move.Noclip = v end })
page.AddToggle({ icon = "🕊️", title = "طيران", desc = "WASD + مسافة — أو الأزرار على الشاشة", default = false,
    callback = function(v)
        Move.Fly = v
        if v then
            StartFly()
            CreateFlyButtons()
        else
            StopFly()
            RemoveFlyButtons()
        end
    end })
page.AddSlider({ icon = "🚀", title = "سرعة الطيران", min = 50, max = 2000, default = 300, suffix = "",
    callback = function(v) Move.FlySpeed = v end })

Utils.AddCleanup(function()
    Move.Noclip = false
    Move.Fly = false
    Move.InfJump = false
    StopFly()
    RemoveFlyButtons()
end)

SP.Movement = Move
