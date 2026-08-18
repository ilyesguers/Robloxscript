--[[
  ═══════════════════════════════════════════════════════════
  SpeedPlus / 3) Utils — أدوات مساعدة مشتركة
  ═══════════════════════════════════════════════════════════
]]
local env = getgenv and getgenv() or _G
local SP = env.SpeedPlus or {}
env.SpeedPlus = SP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera or Camera
end)

local Utils = {}

-- منشئ Instances
function Utils.New(className, props, parent)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

-- إشعار
function Utils.Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3,
        })
    end)
end

-- تنسيق الأرقام: 1.2M / 340K
function Utils.FormatNumber(n)
    n = tonumber(n) or 0
    if n >= 1e9 then return string.format("%.2fB", n / 1e9) end
    if n >= 1e6 then return string.format("%.2fM", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK", n / 1e3) end
    return tostring(math.floor(n))
end

-- سحب العناصر (موبايل + كمبيوتر)
function Utils.MakeDraggable(dragPart, movePart)
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
            local w, h = movePart.AbsoluteSize.X, movePart.AbsoluteSize.Y
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

-- البحث عن ريمون بالاسم (يبحث في ReplicatedStorage)
function Utils.FindRemote(patterns)
    local RS = game:GetService("ReplicatedStorage")
    for _, obj in ipairs(RS:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, pat in ipairs(patterns) do
                if string.find(name, pat, 1, true) then
                    return obj
                end
            end
        end
    end
    return nil
end

-- إطلاق ريمون بأمان (يدعم Event و Function)
function Utils.FireRemote(remote, ...)
    if not remote then return false end
    local args = { ... }
    local ok, err = pcall(function()
        if remote:IsA("RemoteFunction") then
            remote:InvokeServer(unpack(args))
        else
            remote:FireServer(unpack(args))
        end
    end)
    return ok, err
end

-- قراءة إحصائية بأمان
function Utils.GetStat(name)
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    local stat = ls and ls:FindFirstChild(name)
    if stat then
        local v = stat.Value
        return v
    end
    return nil
end

-- البحث عن كلمة في اسم (بصيغة حرة)
function Utils.NameMatches(name, keywords)
    name = string.lower(tostring(name))
    for _, kw in ipairs(keywords) do
        if string.find(name, kw, 1, true) then
            return true
        end
    end
    return false
end

-- قائمة التنظيف: تُستدعى عند إغلاق الواجهة
SP.Cleanups = SP.Cleanups or {}
function Utils.AddCleanup(fn)
    table.insert(SP.Cleanups, fn)
end

function Utils.Shutdown()
    for _, fn in ipairs(SP.Cleanups) do
        pcall(fn)
    end
    SP.Cleanups = {}
end

SP.Utils = Utils
