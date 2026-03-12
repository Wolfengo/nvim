local M = {}

function M.jump_syntax_block(direction)
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then
        vim.cmd(direction == "next" and "normal! }" or "normal! {")
        return
    end

    local current_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local sibling_getter = direction == "next" and "next_named_sibling" or "prev_named_sibling"

    local function first_nonblank_row(row, step)
        local last = vim.api.nvim_buf_line_count(0) - 1
        while row >= 0 and row <= last do
            local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
            if line:match("%S") then
                return row
            end
            row = row + step
        end
        return nil
    end

    while node do
        local sibling = node[sibling_getter] and node[sibling_getter](node)
        while sibling do
            local row = sibling:range()
            if row ~= current_row then
                local target = first_nonblank_row(row, direction == "next" and 1 or -1)
                if target and target ~= current_row then
                    vim.api.nvim_win_set_cursor(0, { target + 1, 0 })
                    return
                end
            end
            sibling = sibling[sibling_getter] and sibling[sibling_getter](sibling)
        end
        node = node:parent()
    end

    vim.cmd(direction == "next" and "normal! }" or "normal! {")
end

function M.jump_line_segment(direction)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local len = #line

    if len == 0 then
        return
    end

    if direction == "right" then
        local i = math.min(col + 1, len)

        while i < len and line:sub(i + 1, i + 1):match("%s") do
            i = i + 1
        end

        while i < len and not line:sub(i + 1, i + 1):match("%s") do
            i = i + 1
        end

        while i < len and line:sub(i + 1, i + 1):match("%s") do
            i = i + 1
        end

        vim.api.nvim_win_set_cursor(0, { row, math.min(i, len - 1) })
        return
    end

    local i = math.min(col + 1, len)

    while i > 1 and line:sub(i, i):match("%s") do
        i = i - 1
    end

    while i > 1 and not line:sub(i - 1, i - 1):match("%s") do
        i = i - 1
    end

    while i > 1 and line:sub(i - 1, i - 1):match("%s") do
        i = i - 1
    end

    vim.api.nvim_win_set_cursor(0, { row, math.max(i - 1, 0) })
end

return M
