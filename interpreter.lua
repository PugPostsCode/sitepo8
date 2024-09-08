--[[
	Interpreter? I barely know her!
]]
local interpreter = {}

-- init
function interpreter:init()
	-- require parser
	self.parser = require("parser")

	-- line of the file is stored in registers!!!
end

-- get file
function interpreter:file(file)
	self.file = self.parser.parse(file)
end

-- update
function interpreter:update()
	-- execute line
	local addressValue = memory[registers.l]
	local instruction = utils.byteToInstruction(addressValue)
	
	print(utils.catTable(addressValue), instruction, registers.l)

	if instruction == "nul" then
		-- next!
		registers.l = registers.l + 1
		
	elseif instruction == "set" then
		-- get memory value to set
		local setLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)
	
		-- set value
		memory[setLocation] = memory[registers.l + 3]

		print(
			"setting "..setLocation.." to "..utils.catTable(memory[registers.l + 3])
		)

		-- inc l register
		registers.l = registers.l + 4
		
	elseif instruction == "mov" then
		-- get memory value to set
		local setLocation = utils.splitHexToNum(
			memory[registers.l + 3],
			memory[registers.l + 4]
		)

		-- get memory value to get
		local getLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)

		-- set value to get
		memory[setLocation] = memory[getLocation]

		-- erase old value
		memory[getLocation] = utils.newByte

		print("moving "..getLocation.." to "..setLocation)

		-- inc l register
		registers.l = registers.l + 1
		
	elseif instruction == "cop" then
		-- get memory value to set
		local setLocation = utils.splitHexToNum(
			memory[registers.l + 3],
			memory[registers.l + 4]
		)

		-- get memory value to get
		local getLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)

		-- set value to get
		memory[setLocation] = memory[getLocation]

		print("copying "..getLocation.." to "..setLocation)

		-- inc l register
		registers.l = registers.l + 5

	elseif instruction == "ain" then
		-- get memory value to load into a
		local newValueLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)
	
		-- set value
		registers.a = memory[newValueLocation]

		print(
			"adding "..utils.catTable(memory[newValueLocation]).." to a register from "..newValueLocation
		)
		
		-- inc l register
		registers.l = registers.l + 3
		
	elseif instruction == "ita" then
		-- move i register to a
		registers.a = registers.i

		print("moving "..utils.catTable(registers.i).." from i to a.")

		-- inc l register
		registers.l = registers.l + 1
		
	elseif instruction == "bin" then
		-- get memory value to load into a
		local newValueLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)
	
		-- set value
		registers.b = memory[newValueLocation]

		print(
			"adding "..utils.catTable(memory[newValueLocation]).." to b register from "..newValueLocation
		)

		-- inc l register
		registers.l = registers.l + 3
		
	elseif instruction == "cot" then
		-- get memory value to set
		local setLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)

		-- set to c
		memory[setLocation] = registers.c

		-- inc l register
		registers.l = registers.l + 3
		
	elseif instruction == "add" then
		-- add a and b registers into c
		registers.c = utils.numToByte(utils.byteToNum(registers.a) + utils.byteToNum(registers.b))

		print(
			"adding values in a and b regester to c: " .. utils.catTable(registers.c)
		)

		-- inc l register
		registers.l = registers.l + 1
		
	elseif instruction == "sub" then
		-- subtract a and b registers into c
		registers.c = utils.numToByte(utils.byteToNum(registers.a) - utils.byteToNum(registers.b))

		print(
			"subtracting values in a and b regester to c: " .. utils.catTable(registers.c)
		)

		-- inc l register
		registers.l = registers.l + 1
		
	elseif instruction == "orr" then
		-- or a and b registers into c
		registers.c = utils.newByte()
		for i = 1, 8 do
			if registers.a[i] == "1"
			or registers.b[i] == "1"
			then
				registers.c[i] = "1"
			end
		end

		print(utils.catTable(registers.a), utils.catTable(registers.b), utils.catTable(registers.c))
		
		-- inc l register
		registers.l = registers.l + 1
		
	elseif instruction == "and" then
		-- and a and b registers into c
		registers.c = utils.newByte()
		for i = 1, 8 do
			if registers.a[i] == "1"
			and registers.b[i] == "1"
			then
				registers.c[i] = "1"
			end
		end

		-- inc l register
		registers.l = registers.l + 1
		
	elseif instruction == "not" then
		-- not a register into c
		registers.c = utils.newByte()
		for i = 1, 8 do
			if registers.a[i] == "0"
			then
				registers.c[i] = "1"
			else
				registers.c[i] = "0"
			end
		end

		-- inc l register
		registers.l = registers.l + 1
		
	elseif instruction == "jmp" then
		-- get jump location
		local jumpLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)

		-- jump to value
		registers.l = jumpLocation
		
		print("jumping to: " .. jumpLocation)
	
	elseif instruction == "jiz" then
		-- get jump location
		local jumpLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)

		-- jump to value
		if utils.byteToNum(registers.c) == 0 then
			registers.l = jumpLocation
		else
			-- inc l register
			registers.l = registers.l + 3
		end
		
	elseif instruction == "jnz" then
		-- get jump location
		local jumpLocation = utils.splitHexToNum(
			memory[registers.l + 1],
			memory[registers.l + 2]
		)

		-- jump to value
		if utils.byteToNum(registers.c) ~= 0 then
			registers.l = jumpLocation
		else
			-- inc l register
			registers.l = registers.l + 3
		end
		
	end

	-- stop program
	if registers.l >= 4095 then
		print("Program finished!")
		function love.update() end
	end
end

-- return
interpreter:init()
return interpreter
