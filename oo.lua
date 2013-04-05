-- Simple OOP library, almost as fast as plain Lua metatable classes.

local oo = {}

function oo.class(...)
	local proto = oo.aug({}, ...)
	proto.__index = proto

	function proto.new(...)
		local self = setmetatable({}, proto)
		if proto.init then
			self:init(...)
		end
		return self
	end

	return proto
end

function oo.aug(target, ...)
	for _, t in ipairs({...}) do
		for k, v in pairs(t) do
			target[k] = v
		end
	end
	return target
end

return oo