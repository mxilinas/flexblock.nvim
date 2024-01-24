local M = {}

--- Insert lines in the current buffer
--- @param first_row integer
--- @param last_row integer
--- @param lines string[]
function M.insert_lines(first_row, last_row, lines)
	vim.api.nvim_buf_set_lines(0, first_row - 1, last_row, true, lines)
	vim.api.nvim_win_set_cursor(0, { first_row, 0 })
end

--- Return the lines from the given range in the current buffer.
--- @param first_row integer
--- @param last_row integer
--- @return table
function M.get_lines(first_row, last_row)
	return vim.api.nvim_buf_get_lines(0, first_row - 1, last_row, true)
end

--- Return the lines of the current visual selection and its start/end rows.
--- @return integer, integer
function M.get_selection()
	local first_row = vim.api.nvim_buf_get_mark(0, "<")[1]
	local last_row = vim.api.nvim_buf_get_mark(0, ">")[1]
	if first_row == 0 or last_row == 0 then
		error("Failed to get selection!")
	end
	return first_row, last_row
end

--- Return the character under the cursor.
--- @return string
function M.getchar()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local line = vim.api.nvim_get_current_line()
	local i = col + 1
	return line:sub(i, i)
end

--- Visually select the block under the cursor.
function M.select_block()
	local blocktype = M.getchar()
	local input = string.format("va%s<Esc>", blocktype)
	vim.api.nvim_input(input)
end

--- True if the given char is a closing brace.
--- @param char string
--- @return boolean
function M.is_brace(char)
	if string.match(char, "[})%]]") then
		return true
	end
	return false
end
assert(M.is_brace("a") == false)
assert(M.is_brace("[") == false)
assert(M.is_brace(")") == true)
assert(M.is_brace("}") == true)
assert(M.is_brace("]") == true)

--- True if the given string is all whitespace.
--- @param str string
--- @return boolean
function M.whitespace(str)
	return not not string.match(str, "^%s*$")
end

return M
