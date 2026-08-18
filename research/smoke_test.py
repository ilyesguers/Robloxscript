#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# اختبار تكامل SpeedPlus: يشتغل اللودر الحقيقي مع وحدات المشروع في بيئة Roblox محاكية
import os, sys, re
from lupa import LuaRuntime

ROOT = "/home/user/Robloxscript"
SP_DIR = os.path.join(ROOT, "SpeedPlus")

# 1) فحص صيغة كل ملف
lua = LuaRuntime(unpack_returned_tuples=True)
files = sorted(os.listdir(SP_DIR))
for f in files:
    if not f.endswith(".lua"): continue
    try:
        lua.execute(f"assert(loadfile({os.path.join(SP_DIR, f)!r}))")
        print(f"  ✓ SYNTAX {f}")
    except Exception as e:
        print(f"  ✗ SYNTAX {f}: {e}")
        sys.exit(1)

# 2) بيئة Roblox محاكية
MOCK = r"""
-- ====== بيئة Roblox وهمية ======
local signal_stub = {
    Connect = function(self, fn) return { Disconnect = function() end } end,
    Wait = function(self) end,
    Disconnect = function(self) end,
}

local instance_mt = {}
function instance_mt.__index(self, k)
    local raw = rawget(self, k)
    if raw ~= nil then return raw end
    if k == "FindFirstChild" then
        return function(self, name, rec)
            for _, c in ipairs(self._children or {}) do
                if rawget(c, "_name") == name then return c end
            end
            return nil
        end
    elseif k == "FindFirstChildOfClass" then
        return function(self, cn)
            for _, c in ipairs(self._children or {}) do
                if rawget(c, "_class") == cn then return c end
            end
            return nil
        end
    elseif k == "GetDescendants" then
        return function() return {} end
    elseif k == "IsA" then
        return function(self, cn) return rawget(self, "_class") == cn or cn == "Instance" end
    elseif k == "Destroy" then
        return function(self) self._destroyed = true end
    elseif k == "GetPropertyChangedSignal" then
        return function() return signal_stub end
    elseif k == "Play" then
        return function() end
    elseif k == "Completed" then
        return signal_stub
    elseif k == "AbsolutePosition" or k == "AbsoluteSize" then
        return { X = 100, Y = 100 }
    elseif k == "Parent" then
        return rawget(self, "_parent")
    elseif k == "Name" then
        return rawget(self, "_name") or "Instance"
    end
    return signal_stub  -- أي خاصية/إشارة غير معروفة: إشارة عامة
end
function instance_mt.__newindex(self, k, v)
    if k == "Parent" then
        local old = rawget(self, "_parent")
        if old and type(old) == "table" then
            local kids = rawget(old, "_children")
            if kids then
                for i, c in ipairs(kids) do
                    if c == self then table.remove(kids, i) break end
                end
            end
        end
        rawset(self, "_parent", v)
        if v and type(v) == "table" then
            local kids = rawget(v, "_children")
            if not kids then kids = {} rawset(v, "_children", kids) end
            table.insert(kids, self)
        end
    elseif k == "Name" then
        rawset(self, "_name", v)
    else
        rawset(self, k, v)
    end
end

local function MakeInst(className)
    return setmetatable({ _class = className, _children = {} }, instance_mt)
end

Instance = { new = function(className) return MakeInst(className) end }

local enumProxy
enumProxy = setmetatable({}, { __index = function(_, k) return enumProxy end })
Enum = enumProxy

Color3 = {
    fromRGB = function(r, g, b) return { r = r, g = g, b = b } end,
    new = function(r, g, b) return { r = r, g = g, b = b } end,
}
ColorSequence = { new = function(...) return {...} end }

UDim2 = {
    new = function(sx, ox, sy, oy) return { X = { Scale = sx, Offset = ox }, Y = { Scale = sy, Offset = oy } } end,
    fromOffset = function(x, y) return { X = { Scale = 0, Offset = x }, Y = { Scale = 0, Offset = y } } end,
    fromScale = function(sx, sy) return { X = { Scale = sx, Offset = 0 }, Y = { Scale = sy, Offset = 0 } } end,
}
UDim = { new = function(scale, offset) return { Scale = scale, Offset = offset } end }
TweenInfo = { new = function(...) return {} end }
Vector2 = { new = function(x, y) return { X = x, Y = y } end }
Vector3 = { new = function(x, y, z) return { X = x, Y = y, Z = z } end }
CFrame = { new = function(...) return { Position = Vector3.new(0,0,0) } end }
CFrame.new = CFrame.new

local function StubService(name)
    return setmetatable({
        Name = name,
        GetPropertyChangedSignal = function() return signal_stub end,
        Connect = function() return signal_stub end,
        SetCore = function() end,
        Create = function() return { Play = function() end, Completed = signal_stub } end,
        Heartbeat = signal_stub,
        RenderStepped = signal_stub,
        Stepped = signal_stub,
        InputBegan = signal_stub,
        InputEnded = signal_stub,
        InputChanged = signal_stub,
        JumpRequest = signal_stub,
        PlayerAdded = signal_stub,
        PlayerRemoving = signal_stub,
        GetPlayers = function() return {} end,
        IsKeyDown = function() return false end,
        GetFocusedTextBox = function() return nil end,
        TouchEnabled = true,
        MouseEnabled = false,
    }, { __index = function(self, k)
        return function() end
    end })
end

local CoreGui = StubService("CoreGui")
local camera = { ViewportSize = { X = 400, Y = 800 } }
workspace = StubService("Workspace")
workspace.CurrentCamera = camera
workspace.FindFirstChild = function() return nil end
workspace.GetDescendants = function() return {} end

local LocalPlayer = {
    Character = nil,
    CharacterAdded = signal_stub,
    FindFirstChild = function() return nil end,
    GetDescendants = function() return {} end,
    Idled = signal_stub,
}
local Players = StubService("Players")
Players.LocalPlayer = LocalPlayer

local function readLocalModule(selfOrUrl, maybeUrl)
    local url = maybeUrl or selfOrUrl
    local name = url:match("SpeedPlus/([%w_]+)%.lua$")
    if not name then return "" end
    local f = io.open("/home/user/Robloxscript/SpeedPlus/" .. name .. ".lua", "r")
    if not f then return "" end
    local content = f:read("*a")
    f:close()
    return content
end

game = {
    GetService = function(self, name)
        local map = {
            Players = Players, CoreGui = CoreGui, TweenService = StubService("TweenService"),
            RunService = StubService("RunService"), UserInputService = StubService("UserInputService"),
            StarterGui = StubService("StarterGui"), TeleportService = StubService("TeleportService"),
            ReplicatedStorage = StubService("ReplicatedStorage"), Lighting = StubService("Lighting"),
            VirtualUser = StubService("VirtualUser"),
        }
        return map[name] or StubService(name)
    end,
    IsLoaded = function() return true end,
    Loaded = signal_stub,
    HttpGet = readLocalModule,
    PlaceId = 95082159892680,
}

task = {
    spawn = function() end,  -- لا نشغل الخيوط في الاختبار
    wait = function() end,
    delay = function() end,
    defer = function() end,
}
warn = function(...) end
getgenv = function() return _G end
print = function(...) end
tick = os.clock
"""

lua.execute(MOCK)

# 3) تشغيل اللودر الحقيقي
loader_src = open(os.path.join(ROOT, "SpeedPlus.lua"), encoding="utf-8").read()
try:
    lua.execute(loader_src)
except Exception as e:
    print("LOADER ERROR ✗:", e)
    sys.exit(1)

# 4) التحقق البنيوي
VERIFY = r"""
local function findByName(root, name)
    local kids = rawget(root, "_children") or {}
    for _, c in ipairs(kids) do
        if rawget(c, "_name") == name then return c end
    end
    return nil
end
local gui = findByName(game:GetService("CoreGui"), "SpeedPlusUI")
assert(gui, "ScreenGui مفقودة")
local window = findByName(gui, "Window")
assert(window, "النافذة مفقودة")
local tabBar = findByName(window, "TabBar")
assert(tabBar, "شريط التبويبات مفقود")
local tabs = 0
for _, c in ipairs(rawget(tabBar, "_children") or {}) do
    if tostring(rawget(c, "_class")) == "TextButton" then tabs = tabs + 1 end
end
assert(tabs == 8, "نتوقع 8 تبويبات، وجدنا " .. tabs)
local pages = findByName(window, "Pages")
local pageCount = #(rawget(pages, "_children") or {})
assert(pageCount == 8, "نتوقع 8 صفحات، وجدنا " .. pageCount)
assert(findByName(gui, "SpeedPlusButton"), "الزر العائم مفقود")
assert(findByName(gui, "Hud"), "شريط HUD مفقود")

-- التحقق من الوحدات
assert(getgenv().SpeedPlus.Config, "Config مفقود")
assert(getgenv().SpeedPlus.Theme, "Theme مفقود")
assert(getgenv().SpeedPlus.Utils, "Utils مفقود")
assert(getgenv().SpeedPlus.Lib, "UI_Lib مفقود")
assert(getgenv().SpeedPlus.Background, "Background مفقود")
assert(getgenv().SpeedPlus.Aura, "Aura مفقود")
assert(getgenv().SpeedPlus.HUD, "HUD مفقود")
assert(getgenv().SpeedPlus.Farm, "Farm مفقود")
assert(getgenv().SpeedPlus.Win, "Win مفقود")
assert(getgenv().SpeedPlus.Economy, "Economy مفقود")
assert(getgenv().SpeedPlus.Movement, "Movement مفقود")
assert(getgenv().SpeedPlus.Visuals, "Visuals مفقود")
assert(getgenv().SpeedPlus.Gravity, "Gravity مفقود")
local pageCountCheck = 0
for _ in pairs(getgenv().SpeedPlus.Pages) do pageCountCheck = pageCountCheck + 1 end
assert(pageCountCheck == 8, "عدد الصفحات المسجلة غير صحيح: " .. pageCountCheck)

-- التحقق من أدوات الصفحات
local P = getgenv().SpeedPlus.Pages
assert(P.Home and P.Speed and P.Win and P.Economy and P.Movement and P.Visuals and P.Gravity and P.Settings,
    "بعض الصفحات غير مسجلة")

-- التحقق من وجود تحكمات في كل صفحة (الميزات أضافت أزرارها)
local function countChildren(pg)
    local root = findByName(window, "Pages")
    for _, c in ipairs(rawget(root, "_children") or {}) do
        if rawget(c, "_name") == pg then
            return #(rawget(c, "_children") or {})
        end
    end
    return 0
end
local speedCount = countChildren("Page_Speed")
local winCount = countChildren("Page_Win")
local gravCount = countChildren("Page_Gravity")
assert(speedCount >= 8, "صفحة السرعة فقيرة: " .. speedCount)
assert(winCount >= 9, "صفحة الفوز فقيرة: " .. winCount)
assert(gravCount >= 8, "صفحة الجاذبية فقيرة: " .. gravCount)

__struct = string.format("البنية سليمة ✓ | تبويبات: %d | صفحات: %d | عناصر السرعة: %d | الفوز: %d | الجاذبية: %d",
    tabs, pageCount, speedCount, winCount, gravCount)
"""

try:
    lua.execute(VERIFY)
    print("INTEGRATION TEST: OK ✓")
    print("STRUCTURE:", lua.eval("__struct"))
except Exception as e:
    print("INTEGRATION ERROR ✗:", e)
    sys.exit(1)
