oo.lua
======

`oo` is a small, flexible class system which acheives almost the same performance as regular Lua classes made with metatables. It used to be part of a LOVE library called Harmony, but the Harmony library itself wasn't particularly useful.

The oo module itself I am quite proud of. Here's why I use it over other Lua OOP libraries:

`new` is an ordinary function in the class table, not a method (i.e. `MyClass.new()` instead of `MyClass:new()` ). 

`init` is the name of the constructor function (as opposed to longer words such as 'constructor' or 'initialize', although this is just a matter of preference - less typing).

## Overview ##

The library contains just 2 functions:

+ `oo.class(...)` creates a class, optionally inheriting from the tables you specify.
+ `oo.aug(target, ...)` copies the properties of the other arguments into the target table

## Tutorial ##

To create a new class, just require the oo file and call oo.class()
	
	local oo = require "oo"
	
	local Point = oo.class()
	
Constructors are defined by adding an 'init' method:
	
	function Point:init(x, y)
		self.x = x or 0
		self.y = y or 0
	end
	
Methods can be added like so:
	
	function Point:moveBy(x, y)
		self.x = self.x + x
		self.y = self.y + y
	end
	
Metamethods work fine too:
	
	function Point:__tostring()
		return "("..self.x..", "..self.y..")"
	end
	
Classes are instantiated with their 'new' function (which does not require the : operator)
	
	local p = Point.new(10, 20)
	p:moveBy(5, 5)
	
	print(p) -- calls __tostring internally, so this prints '(15, 25)'
	
Extending classes is simple, and inheritance works by copying methods into the new class, so instances of derived classes are just as fast as instances of base classes. You can inherit from one or more classes by adding arguments to the oo.class function.
	
	local Rect = oo.class(Point)
	
	function Rect:init(x, y, w, h)
		Point.init(self, x, y) -- calling the super constructor
		self.w = w or 0
		self.h = h or 0
	end
	
	function Rect:scale(amountX, amountY)
		self.w = self.w * amountX
		self.h = self.h * amountY
	end
	
	function Rect:__tostring()
		return string.format("(%d, %d, %d, %d)", self.x, self.y, self.w, self.h)
	end
	
	local r = Rect.new(10, 20, 30, 40)
	r:scale(2, 2)
	r:moveBy(5, 5)
	print(r) -- prints '(15, 25, 60, 80)'
	
Generally, variables are marked as private by putting underscores before their names (like _name). This doesn't give true privacy, but it tells programmers not to access the property from outside the class methods. If you really need true private variables, you can make a local table with weak keys in your class file and use instances as keys:
	
	local Map = oo.class()
	
	-- keys will be removed when there are no other references to them:
	local tileSize = setmetatable({}, {__mode="k"})
	
	function Map:init(tileSize, data)
		tileSize[self] = tileSize
		-- etc.
	end
	
This approach adds very little overhead, but the underscore naming convention is more readable, consistent and is suitable for most people's needs.

Private methods can simply be made as local functions which take a 'self' object as their first argument (such as getListenerPos in Signal.lua)
	
	local function getListenerPos(self, func, scope)
	    -- etc.
	end
	

`oo.aug(target, ...)` will copy the properties of each extra argument into a target table, and return the modified target.
	
	local a = {"one", "two"}
	local b = {foo = "bar"}
	local c = {alive = true}
	
	oo.aug(c, a, b) -- c now contains all the properties of a and b
	
	local d = oo.aug({}, c) -- d is now a shallow copy of c
	

### Signal ###

I also included a `Signal` module, providing a Lua version of AS3-Signals by Robert Penner. Signals are event objects which can have functions (listeners) bound to them. When a Signal is dispatched, all its listeners will be called.

+ `add(func [, scope])` binds a listener to the signal (with an optional scope)
+ `addOnce(func [, scope])` adds a one-time listener
+ `remove(func [, scope])` removes a listener from the signal
+ `removeAll()` removes all listeners
+ `dispatch([...])` calls all listener functions, with whatever arguments are passed

For example, you could use a signal to call a variety of functions upon the death of the player in a game:
	
	local Signal = require "Signal"
	
	local onDeath = Signal.new()
	
	onDeath:add(showDeathScreen)
	
	onDeath:add(function ()
		playAudio(deathMusic)
	end)
	
The scope of a method can be specified by calling add with a second argument.
	
	onDeath:add(player.hide, player) -- will be called with 'player' as the first argument
	
To trigger all the listeners bound to a Signal, use the `dispatch` method:
	
	onDeath:dispatch()
	
Signals can be dispatched with arguments too, which will be passed to every listener.
	
	local onMove = Signal.new()
	
	onMove:add(function (amountX, amountY)
		print("player moved by "..amountX..", "..amountY)
	end)
	
	onMove:dispatch(5, 7)  -- prints 'player moved by 5, 7'
	
Signals can also be disguised as functions (the `__call` metamethod wraps around `dispatch`), allowing them to be used anywhere that a normal callback function can be used.

	onMove(2, 3) -- equivalent to onMove:dispatch(2, 3)
	
One-time listeners can be added with the `addOnce` method. When the signal is dispatched, the one-time listeners will be removed from the listeners table and won't be called again.

A listener can be removed from a Signal using the `remove` method (the arguments are the same as `add` and `addOnce`). To remove all listeners from a signal, call `removeAll`
