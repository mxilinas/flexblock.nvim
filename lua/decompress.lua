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

	local first = string.sub(line, 1, start)
	local list = string.sub(line, start + 1, stop)
	local last = string.sub(line, stop)

	table.insert(lines, first)

	local leading_spaces = string.match(line, "^%s*")
	local indent = leading_spaces .. string.rep(" ", shiftwidth)

	local nesting_level = 0
	local element = ""
	for char in string.gmatch(list, ".") do
		element = element .. char
		if nesting_level == 0 then
			if string.sub(element, -2) == ", " then
				table.insert(lines, indent .. util.remove_surrounding_whitespace(element))
				element = ""
			elseif string.match(string.sub(element, -1), "[%]%}%)]") then
				if string.len(element) ~= 1 then
					table.insert(lines, indent .. util.remove_surrounding_whitespace(string.sub(element, 1, -2)) .. ",")
				end
				element = ""
			end
		end

		if string.match(char, "[%[%(%{]") then
			nesting_level = nesting_level + 1
		elseif string.match(char, "[%]%)%}]") then
			nesting_level = nesting_level - 1
		end
	end

	table.insert(lines, leading_spaces .. last)

	return lines
end

local function test(result)
	for i = 1, #result, 1 do
		print(result[i])
	end
end

print("no elements")
test(decompress("{}", "}", 4))
test(decompress("()", ")", 4))
test(decompress("[]", "]", 4))

print()
print("one element")
test(decompress("{a}", "}", 4))
test(decompress("(a)", ")", 4))
test(decompress("[a]", "]", 4))

print()
print("three elements")
test(decompress("{ a, b, c }", "}", 4))
test(decompress("(a, b, c)", ")", 4))
test(decompress("[a, b, c]", "]", 4))

test(decompress("{ 1, 2, 3, 4 }", "}", 4))

print()
print("Multi-dimensional")
test(decompress("{ { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } }", "}", 4))
test(decompress("[[1, 2, 3], [4, 5, 6], [7, 8, 9]]", "]", 4))

return decompress
