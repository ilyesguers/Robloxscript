#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Smoke test: تشغيل SpeedPlus.lua داخل بيئة Roblox وهمية مصغرة (LuaJIT via lupa)
import sys
from lupa import LuaRuntime

lua = LuaRuntime(unpack_returned_tuples=True)

MOCK = r"""
-- ====== بيئة Roblox وهمية مصغرة ======
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
            for _, c in ipairs(self._children) do
                if c.Name == name then return c end
            end
            return nil
        end
    elseif k == "FindFirstChildOfClass" then
        return function(self, cn)
            for _, c in ipairs(self._children) do
                if c._class == cn then return c end
            end
            return nil
        end
    elseif k == "FindFirstChildWhichIsA" then
        return function() return nil end
    elseif k == "GetDescendants" then
        return function() return {} end
    elseif k == "IsA" then
        return function(self, cn) return self._class == cn or cn == "Instance" end
    elseif k == "Destroy" then
        return function(self) self._destroyed = true end
    elseif k == "GetPropertyChangedSignal" then
        return function() return signal_stub end
    elseif k == "Connect" or k == "Wait" or k == "Disconnect" then
        return function() end
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
    return signal_stub  -- أي خاصية/إشارة غير معروفة: نرجع إشارة عامة
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
    local t = setmetatable({ _class = className, _children = {} }, instance_mt)
    return t
end

Instance = { new = function(className) return MakeInst(className) end }

-- Enum عام (أي قيمة ترجع نفسها)
local enumProxy
enumProxy = setmetatable({}, { __index = function(_, k) return enumProxy end })
Enum = enumProxy

Color3 = {
    fromRGB = function(r, g, b) return { r = r, g = g, b = b } end,
    new = function(r, g, b) return { r = r, g = g, b = b } end,
}
Color3.new = function() return { r = 0, g = 0, b = 0 } end

UDim2 = {
    new = function(sx, ox, sy, oy) return { X = { Scale = sx, Offset = ox }, Y = { Scale = sy, Offset = oy } } end,
    fromOffset = function(x, y) return { X = { Scale = 0, Offset = x }, Y = { Scale = 0, Offset = y } } end,
    fromScale = function(sx, sy) return { X = { Scale = sx, Offset = 0 }, Y = { Scale = sy, Offset = 0 } } end,
}
UDim = { new = function(scale, offset) return { Scale = scale, Offset = offset } end }
TweenInfo = { new = function(...) return {} end }
Vector2 = { new = function(x, y) return { X = x, Y = y } end }
Vector3 = { new = function(x, y, z) return { X = x, Y = y, Z = z } end }

local function StubService(name)
    return setmetatable({
        Name = name,
        GetPropertyChangedSignal = function() return signal_stub end,
        Connect = function() return signal_stub end,
        SetCore = function() end,
        Create = function() return {
            Play = function() end,
            Completed = signal_stub,
        } end,
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
workspace = StubService("Workspace")   -- عام (global) لأنه يُستخدم داخل السكربت
workspace.CurrentCamera = camera
workspace.FindFirstChild = function() return nil end

local LocalPlayer = {
    Character = nil,
    CharacterAdded = signal_stub,
    FindFirstChild = function() return nil end,
    GetDescendants = function() return {} end,
}
local Players = StubService("Players")
Players.LocalPlayer = LocalPlayer

game = {
    GetService = function(self, name)
        local map = {
            Players = Players, CoreGui = CoreGui, TweenService = StubService("TweenService"),
            RunService = StubService("RunService"), UserInputService = StubService("UserInputService"),
            StarterGui = StubService("StarterGui"), TeleportService = StubService("TeleportService"),
            ReplicatedStorage = StubService("ReplicatedStorage"),
        }
        return map[name] or StubService(name)
    end,
    PlaceId = 95082159892680,
}

task = {
    spawn = function() end,   -- لا نشغل الخيوط في الاختبار
    wait = function() end,
    delay = function() end,
    defer = function() end,
}

print = function(...) end
tick = os.clock
workspace = game:GetService("Workspace")
"""

src = open("/home/user/Robloxscript/SpeedPlus.lua", encoding="utf-8").read()
lua.execute(MOCK)
try:
    lua.execute(src)
except Exception as e:
    print("RUNTIME ERROR ✗:", e)
    sys.exit(1)

# ====== فحص بنيوي: نتأكد أن الواجهة بُنيت فعلياً ======
VERIFY = r"""
local function findByName(root, name)
    local kids = rawget(root, "_children") or {}
    for _, c in ipairs(kids) do
        if rawget(c, "_name") == name then return c end
    end
    return nil
end
local CoreGui = game:GetService("CoreGui")
local gui = findByName(CoreGui, "SpeedPlusUI")
assert(gui, "ScreenGui مفقودة")
local window = findByName(gui, "Window")
assert(window, "النافذة مفقودة")
local topBar = findByName(window, "TopBar")
assert(topBar, "شريط العنوان مفقود")
assert(findByName(topBar, "Close"), "زر الإغلاق مفقود")
local tabBar = findByName(window, "TabBar")
assert(tabBar, "شريط التبويبات مفقود")
local tabs = 0
for _, c in ipairs(rawget(tabBar, "_children") or {}) do
    if tostring(rawget(c, "_class")) == "TextButton" then tabs = tabs + 1 end
end
assert(tabs == 7, "نتوقع 7 تبويبات، وجدنا " .. tabs)
local pages = findByName(window, "Pages")
local pageCount = #(rawget(pages, "_children") or {})
assert(pageCount == 7, "نتوقع 7 صفحات، وجدنا " .. pageCount)
assert(findByName(gui, "SpeedPlusButton"), "الزر العائم مفقود")
assert(findByName(gui, "Hud"), "شريط HUD مفقود")
__struct = string.format("البنية سليمة ✓ (7 تبويبات / 7 صفحات / زر عائم / HUD)")
"""

try:
    lua.execute(VERIFY)
    print("RUNTIME SMOKE TEST: OK ✓")
    print("STRUCTURE:", lua.eval("__struct"))
except Exception as e:
    print("STRUCTURE ERROR ✗:", e)
    sys.exit(1)
