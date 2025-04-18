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

	Limb = function(self, _position, _length)
		assert_self(self, "Limb")

		self.position = _position
		self.length   = _length
	end
} 

local function ikchain_solve_forward(self)
	assert_self(self, "IKChain")

	local next = self.segments[#self.segments]
	local i = #self.segments-1
	local current = self.segments[i]
	
	next.position = vec2( love.mouse.getPosition() )
	
	while current ~= nil do
		local direction = next.position - current.position
		direction = vec2_normalize(direction, current.length)
		current.position = next.position - direction	
	
		i = i-1
		next = current
		current = self.segments[ i ]
	end
end;

local function ikchain_solve_backward(self)
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

class [[IKChain]] {
	segments = {};
	root = vec2(0,0);
	solve_forward  = function(self) end;
	solve_backward = function(self) end;

	IKChain = function(self, _segments, _root)
		assert_self(self, "IKChain")

		self.segments = _segments
		self.root = _root
		self.solve_forward  = ikchain_solve_forward
		self.solve_backward = ikchain_solve_backward
	end
}

local segments = {
	new [[Limb]](vec2(0,0),   64),
	new [[Limb]](vec2(10,10), 64),
	new [[Limb]](vec2(20,20), 64),
	new [[Limb]](vec2(30,30), 64)
}

local ikchain = new [[IKChain]](segments, vec2(50,50))

local function draw_segments() 
	love.graphics.setColor(1,0,1,1)
	
	local this = ikchain.segments[1]
	for i = 2, #ikchain.segments do
		local next = ikchain.segments[i]
		love.graphics.circle("fill", this.position.X, this.position.Y, 5)
		love.graphics.line(this.position.X, this.position.Y, next.position.X, next.position.Y)
		this = next
	end

	love.graphics.setColor(1,1,1,1)
	love.graphics.circle("fill", this.position.X, this.position.Y, 5)
end

function love.update(_dt)
	clock = clock + _dt

	for i = 1, 2 do
		ikchain:solve_forward()
		ikchain:solve_backward()
	end
end

function love.draw()
	love.graphics.clear(0.2,0.2,0.2,1)

	--[[
	foot = vec2( love.mouse.getPosition() )
	
	local elbow = pos + get_elbow_pos_local(limb_length, limb_length, foot - pos, bend_sign)
	
	local foot_local = foot - elbow
	foot = elbow + vec2_normalize(foot_local) * limb_length
	
	love.graphics.circle("fill", pos.X, pos.Y, 13)
	love.graphics.line(pos.X, pos.Y, elbow.X, elbow.Y)
	love.graphics.line(elbow.X, elbow.Y, foot.X, foot.Y)
	
	if vec2_len(foot_local) > limb_length then
		pos = pos + foot_local - vec2_normalize(foot_local) * limb_length
	end
]]
	
	draw_segments()

	_display_print()
end