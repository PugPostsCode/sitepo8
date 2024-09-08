--[[
	Simple fantasy console
]]

-- load
function love.load()
	-- master variables
	master = {}
	master.width = 96
	master.height = 96
	master.scale = 1

	rescaleWindow(8)

	-- utils
	utils = require("utils")

	-- memory table
	memory = {}

	for i = 0, 4095 do
		memory[i] = utils.newByte()
	end

	-- cpu registers
	registers = {}
	
	registers.a = utils.newByte()
	registers.b = utils.newByte()
	registers.c = utils.newByte()

	registers.i = utils.newByte()
	inputHandler = require("inputHandler")

	registers.l = 1152 -- $480

	-- identity
	love.filesystem.setIdentity("Sitepo-8")

	love.filesystem.createDirectory("load") -- make sure the folder actually shows up lol
	love.filesystem.remove("load") -- idk if there's a better way to do this :c

	-- load file
	interpreter = require("interpreter")
	
	file = nil
	if love.filesystem.getInfo("file.stp8") ~= nil then
		file = love.filesystem.read("file.stp8")
	end

	if file == nil then
		-- exit with error
		fileError()
	else
		-- actually load file
		interpreter:file(file)
	end
end

-- update
function love.update()
	-- input
	registers.i = inputHandler:update()

	-- interpret next code line
	interpreter:update()
end

-- draw
function love.draw()
	-- scale
	love.graphics.scale(master.scale)

	-- screen memory
	for byte = 0, 1151 do
		for bit = 1, 8 do
			-- only draw if plotted
			if memory[byte][bit] == "1" then
				-- pain
				local bi = bit - 1

				-- calculate x & y
				local x = math.floor(((byte * 8) + bi) % 96)
				local y = math.floor(byte / 12)

				-- plot point
				love.graphics.rectangle("fill", x, y, 1, 1)
			end
		end
	end
end

-- rescale the window
function rescaleWindow(scale)
	love.window.setMode(master.width * scale, master.height * scale)
	master.scale = scale
end

-- no file supplied
function fileError()
	-- reset update
	function love.update() end

	-- draw
	function love.draw()
		love.graphics.print(
			"File does not exist!\nCreate a file titled \"file.stp8\" in the Sitepo-8 folder for the program to run!",
			1, 1
		)
	end
end
