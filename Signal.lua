local oo = require "oo"

local Listener = oo.class()

function Listener:init(f, scope)
    self.func = f
    self.scope = scope
end

function Listener:__call(...)
    if self.scope == nil then
        self.func(...)
    else
        self.func(self.scope, ...)
    end
end


local Signal = oo.class()

function Signal:init()
    self.listeners = {}
end

local function getListenerPos(self, func, scope)
    for pos, l in ipairs(self.listeners) do
        if l.func == func and l.scope == scope then
            return pos
        end
    end
end

function Signal:add(func, scope)
    local l = Listener.new(func, scope)
    table.insert(self.listeners, l)
    return l
end

function Signal:addOnce(func, scope)
    self:add(func, scope).once = true
end

function Signal:remove(func, scope)
    table.remove(self.listeners, getListenerPos(self, func, scope))
end

function Signal:removeAll()
    for i in ipairs(self.listeners) do
       self.listeners[i] = nil 
    end
end

function Signal:dispatch(...)
    for i, l in ipairs(self.listeners) do
        l(...)
        if l.once then
            table.remove(self.listeners, i)
        end
    end
end

function Signal:__call(...)
    self:dispatch(...)
end

return Signal
