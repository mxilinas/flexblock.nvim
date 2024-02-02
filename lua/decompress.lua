local util = require("util")

local patterns = {
	["}"] = "%b{}",
	[")"] = "%b()",
	["]"] = "%b[]",
}

local function print_table(table)
	for i = 1, #table, 1 do
		print(table[i])
	end
end

--- True if two tables are equal
local function assert_equal_table(t0, t1)
	assert(#t0 == #t1)
	for i = 1, #t0, 1 do
		assert(t0[i] == t1[i])
	end
end

--- Unfold a one-line block into multiple lines.
--- @param line string
--- @param blocktype string
--- @return table
local function decompress(line, blocktype, shiftwidth)
	local lines = {}

	local start, stop = string.find(line, patterns[blocktype])

	local first = string.sub(line, 1, start)
	local data = string.sub(line, start + 1, stop)
	local last = string.sub(line, stop)

	table.insert(lines, first)

	local leading_spaces = string.match(line, "^%s*")
	local indent = leading_spaces .. string.rep(" ", shiftwidth)

	local nesting_level = 0
	local element = ""
	for char in string.gmatch(data, ".") do
		element = element .. char
		local last_char = string.sub(element, -1)

		if nesting_level == 0 then
			if last_char == "," then
				if not util.is_whitespace(element) then
					local el = util.rm_whitespace(element)
					table.insert(lines, indent .. el)
				end
				element = ""
			elseif last_char == " " then
				if not util.is_whitespace(element) then
					local el = util.rm_whitespace(element)
					table.insert(lines, indent .. el .. ",")
				end
				element = ""
			elseif string.match(last_char, "[%]%}%)]") then
				if #element > 1 then
					local el = util.rm_whitespace(string.sub(element, 1, -2))
					table.insert(lines, indent .. el .. ",")
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

assert_equal_table(decompress("{}", "}", 4), { "{", "}" })
assert_equal_table(decompress("[]", "]", 4), { "[", "]" })
assert_equal_table(decompress("()", ")", 4), { "(", ")" })

assert_equal_table(decompress("{a}", "}", 4), { "{", "    a,", "}" })
assert_equal_table(decompress("[a]", "]", 4), { "[", "    a,", "]" })
assert_equal_table(decompress("(a)", ")", 4), { "(", "    a,", ")" })

assert_equal_table(decompress("{a,b}", "}", 4), { "{", "    a,", "    b,", "}" })
assert_equal_table(decompress("[a,b]", "]", 4), { "[", "    a,", "    b,", "]" })
assert_equal_table(decompress("(a,b)", ")", 4), { "(", "    a,", "    b,", ")" })

assert_equal_table(decompress("{a,b,}", "}", 4), { "{", "    a,", "    b,", "}" })
assert_equal_table(decompress("[a,b,]", "]", 4), { "[", "    a,", "    b,", "]" })
assert_equal_table(decompress("(a,b,)", ")", 4), { "(", "    a,", "    b,", ")" })

assert_equal_table(decompress("{ a, b, }", "}", 4), { "{", "    a,", "    b,", "}" })
assert_equal_table(decompress("[ a, b, ]", "]", 4), { "[", "    a,", "    b,", "]" })
assert_equal_table(decompress("( a, b, )", ")", 4), { "(", "    a,", "    b,", ")" })

assert_equal_table(decompress("{ a, b }", "}", 4), { "{", "    a,", "    b,", "}" })
assert_equal_table(decompress("[ a, b ]", "]", 4), { "[", "    a,", "    b,", "]" })
assert_equal_table(decompress("( a, b )", ")", 4), { "(", "    a,", "    b,", ")" })

assert_equal_table(decompress("{a, b}", "}", 4), { "{", "    a,", "    b,", "}" })
assert_equal_table(decompress("[a, b]", "]", 4), { "[", "    a,", "    b,", "]" })
assert_equal_table(decompress("(a, b)", ")", 4), { "(", "    a,", "    b,", ")" })

return decompress
