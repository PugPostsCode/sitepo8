--[[
	Parse .stp8 files
]]
local parser = {}

-- parse a file as string
function parser.parse(file)
	-- group
	local groups = {}

	local group = ""
	local commentBypass = false
	for i = 1, #file do
		-- char
		local char = string.sub(file, i, i)
	
		-- ignore comments
		if char == "#" then
			commentBypass = true
		elseif commentBypass == true
		and char == "\n"
		then
			commentBypass = false
		end

		-- grouping
		if not commentBypass then
			if char == " "
			or char == "\t"
			or char == "\n"
			then
				-- push group and reset
				if group ~= "" then
					table.insert(groups, group)
					group = ""
				end
			else
				-- add char to group
				group = group .. char
			end
		end
	end

	print("-- Groups:")
	for i = 1, #groups do
		print(groups[i])
	end
	print("")

	-- tokenise
	local tokens = {}

	for i = 1, #groups do
		-- string
		local string = groups[i]

		local firstChar = string.sub(string, 1, 1)

		local token = {}

		-- get token
		if firstChar == ">" then
			-- is address specifier
			token.flavour = "address specifier"
			token.literal = utils.newHex(string.sub(string, 3, -1))
			
		elseif firstChar == "%" then
			-- is binary number
			token.flavour = "number bin"
			token.literal = utils.newByte(string.sub(string, 2, -1))
			
		elseif firstChar == "$" then
			-- is hex number
			token.flavour = "number hex"
			token.literal = utils.newHex(string.sub(string, 2, -1))
			
		else
			-- is instruction
			token.flavour = "instruction"
			token.literal = string
		end

		-- push token
		table.insert(tokens, token)
	end

	print("-- Tokens:")
	for i = 1, #tokens do
		print(tokens[i].flavour, tokens[i].literal)
	end
	print("")

	-- load into memory
	print("-- Loading into memory:")
	local memoryIndex = 1152 -- start at $480
	for i = 1, #tokens do
		-- get token
		local token = tokens[i]
	
		-- put into memory
		if token.flavour == "address specifier" then
			-- accress specification
			memoryIndex = utils.hexToNum(token.literal)
			
			print("new memory index: " .. memoryIndex)
			
		elseif token.flavour == "number bin" then
			-- binary number
			memory[memoryIndex] = token.literal

			memoryIndex = memoryIndex + 1

			print(memoryIndex, "bin")
			
		elseif token.flavour == "number hex" then
			-- hex number
			local low, high = utils.numToHex(utils.hexToNum(token.literal))
			
			memory[memoryIndex] = low
			memory[memoryIndex + 1] = high

			memoryIndex = memoryIndex + 2

			print(memoryIndex, "hex")
		
		elseif token.flavour == "instruction" then
			-- instruction
			memory[memoryIndex] = utils.instructionToByte(token.literal)
			
			memoryIndex = memoryIndex + 1

			print(memoryIndex, "instruction: " .. token.literal)
		
		end
	end
	print("")

	-- done!
end

-- return
return parser
