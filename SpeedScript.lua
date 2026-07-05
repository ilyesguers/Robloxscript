-- [[ Shadow Hub V7.0 | Elite Demon & Pathfinding Arc ]] --
-- المطور: Zero 👾 | نظام محصن بالكامل

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- مسح الواجهة القديمة
if CoreGui:FindFirstChild("ShadowEliteV5") then
    CoreGui.ShadowEliteV5:Destroy()
end

-- ==========================================
-- 1. نظام الإشعارات (الاستخبارات)
-- ==========================================
local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3,
    })
end

-- ==========================================
-- 2. بناء الواجهة الاحترافية (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowEliteV5"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local AlienBtn = Instance.new("TextButton")
AlienBtn.Size = UDim2.new(0, 55, 0, 55)
AlienBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
AlienBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
AlienBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
AlienBtn.BorderSizePixel = 2
AlienBtn.Text = "👾"
AlienBtn.TextScaled = true
AlienBtn.Parent = ScreenGui
Instance.new("UICorner", AlienBtn).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 500)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(150, 0, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = " Shadow Hub V7.0 | SYSTEM: ZERO"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 700)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Parent = Scroll
Layout.Padding = UDim.new(0, 10)

-- ==========================================
-- 3. التحريك المخصص للهواتف
-- ==========================================
local function MakeMobileDraggable(dragPart, movePart)
    local dragging, dragInput, mousePos, framePos
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = movePart.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - mousePos
            movePart.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

MakeMobileDraggable(AlienBtn, AlienBtn)
MakeMobileDraggable(TopBar, MainFrame)

AlienBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local function CreateToggle(text, callback)
    local state = false
    local Btn = Instance.new("TextButton", Scroll)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.Text = "❌ " .. text
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 70) or Color3.fromRGB(40, 40, 40)
        Btn.Text = (state and "✅ " or "❌ ") .. text
        callback(state)
    end)
end

-- ==========================================
-- 4. محرك زيرو (Zero Engine & Pathfinding)
-- ==========================================
_G.AutoWin = false
_G.AutoKeys = false
_G.AutoOrbs = false
_G.AutoBoss = false

-- دالة المشي الذكي والطبيعي (تحريك الأرجل وتفادي العقبات)
local function SmartWalkTo(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local hum = char.Humanoid
    local root = char.HumanoidRootPart

    -- إنشاء مسار لتفادي العقبات
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentWalkableClimb = 2,
        WaypointSpacing = 4
    })

    local success, _ = pcall(function()
        path:ComputeAsync(root.Position, targetPos)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            -- التوقف إذا تم إلغاء التفعيل
            if not _G.AutoWin and not _G.AutoKeys then break end
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                hum.Jump = true
            end
            hum:MoveTo(waypoint.Position)
            hum.MoveToFinished:Wait() -- انتظار الوصول للنقطة للتحرك بشكل طبيعي
        end
    else
        -- في حال فشل إيجاد مسار، المشي المباشر للهدف
        hum:MoveTo(targetPos)
        hum.MoveToFinished:Wait()
    end
end

-- ميزة 1: المشي الطبيعي للنهاية (Wins)
CreateToggle("🏆 المشي الطبيعي للحصول على Wins", function(state)
    _G.AutoWin = state
    task.spawn(function()
        while _G.AutoWin do
            task.wait(1)
            pcall(function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoWin then break end
                    if obj:IsA("Part") or obj:IsA("MeshPart") then
                        local name = obj.Name:lower()
                        if name:match("win") or name:match("end") or obj.BrickColor.Name == "New Yeller" then
                            -- جعل اللاعب يمشي بشكل شرعي ومضمون للهدف
                            SmartWalkTo(obj.Position)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 2: البحث الاستراتيجي عن المفتاح
CreateToggle("🔑 إحضار المفتاح الذهبي (مع تنبيه)", function(state)
    _G.AutoKeys = state
    task.spawn(function()
        while _G.AutoKeys do
            task.wait(2)
            pcall(function()
                local keyFound = false
                local targetKey = nil
                
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:match("key") or name:match("golden") then
                            keyFound = true
                            targetKey = obj
                            break
                        end
                    end
                end
                
                if keyFound and targetKey then
                    SmartWalkTo(targetKey.Position)
                elseif _G.AutoKeys then
                    Notify("Zero 👾 System", "الرادار: لا يوجد مفتاح في الخريطة حالياً.")
                    task.wait(5) -- استراحة قبل الفحص مجدداً
                end
            end)
        end
    end)
end)

-- ميزة 3: الجذب المغناطيسي للكرات (بدون حركة)
CreateToggle("🟡 جذب الكرات عن بعد (لا انتقال)", function(state)
    _G.AutoOrbs = state
    task.spawn(function()
        while _G.AutoOrbs do
            task.wait(0.1)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart
                
                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoOrbs then break end
                    if obj:IsA("BasePart") and obj:FindFirstChildWhichIsA("TouchTransmitter") then
                        local name = obj.Name:lower()
                        if name:match("orb") or obj.Material == Enum.Material.Neon then
                            -- استخدام الدالة النخبوية لاختراق اللمس عن بعد
                            firetouchinterest(root, obj, 0)
                            task.wait(0.01)
                            firetouchinterest(root, obj, 1)
                        end
                    end
                end
            end)
        end
    end)
end)

-- ميزة 4: آلة الفرم الوحشية (Boss Farm)
CreateToggle("⚔️ آلة فرم الزعيم (Boss Farm)", function(state)
    _G.AutoBoss = state
    task.spawn(function()
        while _G.AutoBoss do
            task.wait(0.1)
            pcall(function()
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local root = char.HumanoidRootPart

                for _, obj in pairs(workspace:GetDescendants()) do
                    if not _G.AutoBoss then break end
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():match("boss") then
                        if obj.Humanoid.Health > 0 then
                            local bossRoot = obj:FindFirstChild("HumanoidRootPart")
                            if bossRoot then
                                -- الانتقال والتمركز في النقطة العمياء خلف الزعيم
                                root.CFrame = bossRoot.CFrame * CFrame.new(0, 0, 5)
                                
                                -- تجهيز واستخدام السلاح باستمرار
                                local tool = char:FindFirstChildWhichIsA("Tool") or LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool")
                                if tool then
                                    tool.Parent = char
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

print("Zero 👾 System Fully Initialized.")
Notify("استجابة شيطانية", "تم تفعيل الحد الأقصى للنظام بنجاح.")
