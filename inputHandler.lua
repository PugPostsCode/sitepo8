--[[
	Handle input
]]
local inputHandler = {}

-- init
function inputHandler:init()
	-- keys
	self.up = {"up", "w"}
	self.dn = {"down", "s"}
	self.lt = {"left", "a"}
	self.rt = {"right", "d"}
	
	self.one = {"c", "j"}
	self.two = {"x", "k"}
	self.thr = {"z", "l"}
	
	self.st = {"return", "space"}
end

-- the uhhhh
function inputHandler:update()
	-- return
	local input = utils.newByte()

	-- "dpad"
	if self:isDown("up") then input[1] = 1 end
	if self:isDown("dn") then input[2] = 1 end
	if self:isDown("lt") then input[3] = 1 end
	if self:isDown("rt") then input[4] = 1 end

	-- "face buttons"
	if self:isDown("one") then input[5] = 1 end
	if self:isDown("two") then input[6] = 1 end
	if self:isDown("thr") then input[7] = 1 end

	-- "start"
	if self:isDown("st") then input[8] = 1 end

	-- return
	return input
end

-- more versatile inputs
function inputHandler:isDown(keys)
	return love.keyboard.isDown(self[keys])
end

-- return module
inputHandler:init()
return inputHandler
