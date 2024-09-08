--[[
	Functions for handling bytes, bits, and hex values
]]
local utils = {}

-- new binary table, optionally from a string
function utils.newByte(string)
	-- return
	local ret = {"0", "0", "0", "0", "0", "0", "0", "0"}
	if string == nil then return ret end -- return if string is nil

	-- convert string into byte table
	for i = 1, 8 do
		ret[i] = string.sub(string, i, i)
	end

	-- return
	return ret
end

-- comvert a number to a byte
function utils.numToByte(num)
	-- returns a table of bits, least significant first.
	local t = {} -- will contain the bits
	while num > 0 do
		rest = math.fmod(num,2)
		t[#t + 1] = tostring(rest)
		num = (num - rest) / 2
	end

	-- only length of 8
	while #t < 8 do
		t[#t + 1] = "0"
	end

	while #t > 8 do
		table.remove(t, #t)
	end

	-- reverse to least significant last
	for i = 1, math.floor(#t / 2) do
		local temp = t[i]
		t[i] = t[#t - (i - 1)]
		t[#t - (i - 1)] = temp
	end

	-- return 
	return t
end

-- comvert a byte to a number
function utils.byteToNum(byte)
	byte = utils.catTable(byte)
	byte = tonumber(byte, 2)

	return byte
end

-- new hex table, optionally from a string
function utils.newHex(string)
	-- return
	local ret = {"0", "0", "0"}
	if string == nil then return ret end -- return if string is nil

	-- convert string into byte table
	for i = 1, 3 do
		ret[i] = string.sub(string, i, i)
	end

	-- return
	return ret
end

-- comvert a number to a hex
function utils.numToHex(num)
	-- returns a table of bits, least significant first.
	local t = {} -- will contain the bits
	while num > 0 do
		rest = math.fmod(num,2)
		t[#t + 1] = tostring(rest)
		num = (num - rest) / 2
	end

	-- only length of 8
	while #t < 16 do
		t[#t + 1] = "0"
	end

	while #t > 16 do
		table.remove(t, #t)
	end

	-- reverse to least significant last
	for i = 1, math.floor(#t / 2) do
		local temp = t[i]
		t[i] = t[#t - (i - 1)]
		t[#t - (i - 1)] = temp
	end

	-- split into low and high
	local low = {}
	local high = {}

	for i = 1, 8 do
		table.insert(high, t[i])
		table.insert(low, t[i+8])
	end

	-- return 
	return low, high
end

-- convert a hex value to a number
function utils.hexToNum(hex)
	-- to string
	local hexNum = ""
	for i = 1, 3 do
		hexNum = hexNum .. hex[i]
	end

	-- return
	return tonumber(hexNum, 16)
end

-- convert a high/low split hex value to a number
function utils.splitHexToNum(low, high)
	--
	local ret = {}

	for i = 1, 8 do
		table.insert(ret, high[i])
	end

	for i = 1, 8 do
		table.insert(ret, low[i])
	end

	return utils.byteToNum(ret)
end

-- increment a hex value
function utils.incHex(hex)
	-- return
	local ret = utils.newHex()

	-- variables
	local hexStates = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	hexStates[0] = "0"

	local carry = false

	-- loop
	for i = 3, 1, -1 do
		-- find numerical value
		local hexState = nil
		for j = 0, 15 do
			if hex[i] == hexStates[j] then
				hexState = j
			end
		end

		-- apply
		if carry then
			if hexState < 15 then
				-- increment
				ret[i] = hexStates[hexState + 1]
				carry = false
			end
		else
			if i == #hex then
				if hexState < 15 then
					-- increment
					ret[i] = hexStates[hexState + 1]
				else
					-- stay 0 and carry
					carry = true
				end
			else
				-- don't
				ret[i] = hex[i]
			end
		end
	end

	-- return
	return ret
end

-- concatenate table
function utils.catTable(table)
	local ret = ""
	for i = 1, #table do
		ret = ret .. table[i]
	end
	return ret
end

-- convert an instruction into a byte
function utils.instructionToByte(instruction)
	-- byte as string
	local byte = "0000"

	-- switch
	if instruction == "set" then
		byte = "0001"
	elseif instruction == "mov" then
		byte = "0010"
	elseif instruction == "cop" then
		byte = "0011"
	elseif instruction == "ain" then
		byte = "0100"
	elseif instruction == "ita" then
		byte = "0101"
	elseif instruction == "bin" then
		byte = "0110"
	elseif instruction == "cot" then
		byte = "0111"
	elseif instruction == "add" then
		byte = "1000"
	elseif instruction == "sub" then
		byte = "1001"
	elseif instruction == "orr" then
		byte = "1010"
	elseif instruction == "and" then
		byte = "1011"
	elseif instruction == "not" then
		byte = "1100"
	elseif instruction == "jmp" then
		byte = "1101"
	elseif instruction == "jiz" then
		byte = "1110"
	elseif instruction == "jnz" then
		byte = "1111"
	end

	-- first four bits
	byte = "0000" .. byte

	-- to byte
	byte = utils.newByte(byte)

	-- return
	return byte
end

-- convert a byte into an instruction
function utils.byteToInstruction(byte)
	-- byte as string
	local byte = utils.catTable(byte)

	local instruction = "nul"

	-- switch
	if byte == "00000001" then
		instruction = "set"
	elseif byte == "00000010" then
		instruction = "mov"
	elseif byte == "00000011" then
		instruction = "cop"
	elseif byte == "00000100" then
		instruction = "ain"
	elseif byte == "00000101" then
		instruction = "ita"
	elseif byte == "00000110" then
		instruction = "bin"
	elseif byte == "00000111" then
		instruction = "cot"
	elseif byte == "00001000" then
		instruction = "add"
	elseif byte == "00001001" then
		instruction = "sub"
	elseif byte == "00001010" then
		instruction = "orr"
	elseif byte == "00001011" then
		instruction = "and"
	elseif byte == "00001100" then
		instruction = "not"
	elseif byte == "00001101" then
		instruction = "jmp"
	elseif byte == "00001110" then
		instruction = "jiz"
	elseif byte == "00001111" then
		instruction = "jnz"
	end

	-- return
	return instruction
end

-- return
return utils
