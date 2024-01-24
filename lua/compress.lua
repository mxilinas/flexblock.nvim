--- Compress a multi-line block.
--- @param lines string[]
--- @param blocktype string
--- @return string
local function compress(lines, blocktype)
	local line = lines[1]

	if #lines == 2 then
		return line .. (string.gsub(lines[2], "^%s*", ""))
	end

	if blocktype == "}" then
		line = line .. " "
	end

	for i = 2, #lines - 1, 1 do
		if string.match(lines[i], "^%s*$") then
			goto continue
		end

		local elem = string.match(lines[i], "%s*(.-),?$")

		line = line .. elem
		if i == #lines - 1 then
			if blocktype == "}" then
				line = line .. " "
			end
		else
			if string.sub(elem, -1) == "," then
				line = line .. " "
			else
				line = line .. "," .. " "
			end
		end

		::continue::
	end

	return line .. string.gsub(lines[#lines], "^%s*", "")
end

assert(compress({ "(", "    )" }, ")") == "()")
assert(compress({ "[", "]" }, "]") == "[]")
assert(compress({ "{", "}" }, "}") == "{}")
assert(compress({ "[", "a,", "]" }, "]") == "[a]")
assert(compress({ "{", "a,", "}" }, "}") == "{ a }")
assert(compress({ "[", "a,", "atg", "]" }, "]") == "[a, atg]")
assert(compress({ "{", "a,", "b", "}" }, "}") == "{ a, b }")
assert(compress({ "[", "    a,", "    ]" }, "]") == "[a]")
assert(compress({ "[", "[x, y],", "]" }, "]") == "[[x, y]]")
assert(compress({ "[", "[x, y],", "[z, u]", "]" }, "]") == "[[x, y], [z, u]]")
assert(compress({ "{", "[x, y],", "[z, u]", "}" }, "}") == "{ [x, y], [z, u] }")

return compress
