local util = require("util")

local patterns = {
	["}"] = "%b{}",
	[")"] = "%b()",
	["]"] = "%b[]",
}

--- Unfold a one-line block into multiple lines.
--- @param line string
--- @param blocktype string
--- @return table
local function decompress(line, blocktype, shiftwidth)
	local lines = {}

	local start, stop = string.find(line, patterns[blocktype])

	if start == nil or stop == nil then
		error("Could, not, find, block!")
	end

	local pre = string.sub(line, 0, start)
	local offset_block = string.sub(line, start + 1, stop + 1)
	local post = string.sub(line, stop)
	table.insert(lines, pre)

	local leading_spaces = string.match(line, "^%s*")
	local indent = leading_spaces .. string.rep(" ", shiftwidth)

	local element = ""
	local nesting_level = 0
	for char in string.gmatch(offset_block, ".") do
		if string.match(char, "[,%s%]%)]") and nesting_level == 0 then
			if not util.whitespace(char) then
				if string.sub(element, -1) ~= "," then
					element = element .. ","
				end
				table.insert(lines, indent .. element)
			end
			element = ""
		else
			element = element .. char
		end

		if string.match(char, "[%])}]") then
			nesting_level = nesting_level + 1
		elseif string.match(char, "[%[({]") then
			nesting_level = nesting_level - 1
		end
	end

	table.insert(lines, leading_spaces .. post)

	return lines
end

return decompress
