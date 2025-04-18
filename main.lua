---------------------------------
--! @file main.lua
--! @author Argore
--! @brief Template LÖVE2D Project
--! @version 0.1
--! @date 2025-04-04
--! 
--! @copyright Copyright (c) 2025 Argore
---------------------------------

local _type = type
function _G.type(v)
	local mt = getmetatable(v)
	if mt and mt.__type then
		return mt.__type()
	end
	return _type(v)
end

require "mv_vec"
require "print"
require "class"

local clock = 0.0

local function assert_self(p_self, p_typename)
	if type(p_self) ~= p_typename then error("Expected '" .. p_typename .. "'. Did you mean : instead of . ?") end
end

class [[Limb]] {
	position = vec2(0,0);
	length = 10;
	children = {};
	
	draw = function(self)
		local pos = self.position
		
		if #self.children == 0 then
			love.graphics.setColor(1,1,1,1)
		else
			love.graphics.setColor(1,0,1,1)
		end
		love.graphics.circle("fill", pos.X, pos.Y, 5)
		
		for i = 1, #self.children do
			local child = self.children[i]
			if child then
				local cpos = child.position
					
				love.graphics.line(pos.X, pos.Y, cpos.X, cpos.Y)
	
				child:draw()
			end
		end
		
		love.graphics.setColor(1,1,1,1)
	end;

	Limb = function(self, _position, _length)
		assert_self(self, "Limb")

		self.position = _position
		self.length   = _length
	end
} 

local function ikchain_solve_forward(self, _dt)
	assert_self(self, "IKChain")

	local next = self.segments[#self.segments]
	local i = #self.segments-1
	local current = self.segments[i]
	
	while current ~= nil do
		local direction = next.position - current.position
		direction = vec2_normalize(direction, current.length)
		current.position = next.position - direction
	
		i = i-1
		next = current
		current = self.segments[ i ]
	end
end;

local function ikchain_solve_backward(self, _dt)
	assert_self(self, "IKChain")
	
	local previous = self.segments[1]
	local i = 2
	local current = self.segments[i]
	
	previous.position = self.root
	
	while current ~= nil do
		local direction = current.position - previous.position
		direction = vec2_normalize(direction, previous.length)
		current.position = previous.position + direction
	
		i = i+1
		previous = current
		current = self.segments[ i ]
	end
end

local function ikchain_draw(self)
	self.segments[1]:draw()
end

class [[IKChain]] {
	segments = {};
	root = vec2(0,0);
	end_effector = vec2(0,0);
	solve_forward  = function(self, _dt) end;
	solve_backward = function(self, _dt) end;
	draw = function(self) end;

	IKChain = function(self, _segments, _root)
		assert_self(self, "IKChain")

		self.segments = _segments
		self.root = _root
		self.solve_forward  = ikchain_solve_forward
		self.solve_backward = ikchain_solve_backward
		self.draw = ikchain_draw

		for i = 1, #_segments-1 do
			table.insert(self.segments[i].children, _segments[i+1])
		end
	end;

	set_end_effector = function (self, _pos)
		assert_self(self, "IKChain")
		--self.segments[#self.segments].position = _pos
		self.end_effector = _pos
	end;

	solve = function(self)
		for i = 1, 10 do
			self:solve_forward(0.1)
			self:solve_backward(0.1)
		end
	end
}

local len = 100
local num_segments = 4

local segments = {}
for i=1, num_segments do
	segments[#segments+1] = new [[Limb]](vec2(i*len,i*len), len);
end

local wip_segments = {}

local w,h = love.window.getMode()
local ikchain  = new [[IKChain]](segments, vec2(w/2,h/2))
local end_pos = vec2(0,0)

local press_timer = 0

function love.update(_dt)
	clock = clock + _dt
	
	if press_timer <= 0 and love.mouse.isDown(2) then
		press_timer = 0.1

		wip_segments[#wip_segments+1] = vec2(love.mouse.getPosition())

		print("pressed")
	elseif not love.mouse.isDown(2) then
		press_timer = press_timer - _dt
	end

	if love.mouse.isDown(1) then
		end_pos = vec2(love.mouse.getPosition())
	end

	do -- ikchain
		local leg_clock = clock * 10
		local target_end_pos = vec2(math.cos(leg_clock), math.sin(leg_clock)*0.5) * 64 + end_pos
		ikchain:set_end_effector(target_end_pos)
			
		local epos = ikchain.segments[#ikchain.segments].position
		ikchain.segments[#ikchain.segments].position = epos + (ikchain.end_effector - epos) * _dt * 10
		ikchain:solve()
	end

	

end

function love.draw()
	love.graphics.clear(0.2,0.2,0.2,1)
	
	ikchain:draw()
	

	-- draw wip segments

	love.graphics.setColor(0.8,0.8,0,1)	
	if #wip_segments > 1 then
		local this = wip_segments[1]

		for i = 2, #wip_segments do
			local next = wip_segments[i]
			love.graphics.circle("fill", this.X, this.Y, 5)
			love.graphics.line(this.X, this.Y, next.X, next.Y)
			this = next
		end
		
		love.graphics.setColor(1,1,1,1)
		love.graphics.circle("fill", this.X, this.Y, 5)
	elseif #wip_segments > 0 then
		love.graphics.setColor(1,1,1,1)
		love.graphics.circle("fill", wip_segments[1].X, wip_segments[1].Y, 5)
	end
	love.graphics.setColor(1,1,1,1)


	_display_print()
end