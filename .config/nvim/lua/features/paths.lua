local M = {}

local namespace = vim.api.nvim_create_namespace("UserPathLinks")
local pattern = [[[%w%._%-%/\\]+:%d+:%d+|[%w%._%-%/\\]+:%d+|[%w%._%-%/\\]+]]

local function parse_from_line(line)
    local patterns = {
        "([%w%._%-%/\\]+):(%d+):(%d+)",
        "([%w%._%-%/\\]+):(%d+)",
        "([%w%._%-%/\\]+)",
    }

    for _, item in ipairs(patterns) do
        local path, row, col = line:match(item)
        if path then
            return path, row, col
        end
    end
end

function M.resolve(path)
    local resolved = vim.fs.normalize(path)
    if vim.fn.filereadable(resolved) == 0 then
        resolved = vim.fs.normalize(vim.fn.getcwd() .. "/" .. path)
    end
    if vim.fn.filereadable(resolved) == 0 then
        return nil
    end
    return resolved
end

function M.open_under_cursor()
    local cfile = vim.fn.expand("<cfile>")
    local path, row, col = parse_from_line(cfile)
    if not path then
        return
    end

    local resolved = M.resolve(path)
    if not resolved then
        vim.notify("File not found: " .. path, vim.log.levels.WARN)
        return
    end

    vim.cmd("edit " .. vim.fn.fnameescape(resolved))
    if row then
        vim.api.nvim_win_set_cursor(0, { tonumber(row), math.max((tonumber(col) or 1) - 1, 0) })
    end
end

function M.highlight_buffer(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local last = vim.api.nvim_buf_line_count(bufnr)
    for row = 0, last - 1 do
        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
        local start = 1
        while true do
            local s, e = line:find(pattern, start)
            if not s then
                break
            end
            local text = line:sub(s, e)
            local path = parse_from_line(text)
            if path and M.resolve(path) then
                vim.api.nvim_buf_add_highlight(bufnr, namespace, "Underlined", row, s - 1, e)
            end
            start = e + 1
        end
    end
end

function M.setup_buffer(event)
    local opts = { buffer = event.buf }
    vim.keymap.set("n", "gf", M.open_under_cursor, opts)
    vim.keymap.set("n", "<CR>", M.open_under_cursor, opts)

    local group = vim.api.nvim_create_augroup("UserPathLinks:" .. event.buf, { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
        group = group,
        buffer = event.buf,
        callback = function()
            M.highlight_buffer(event.buf)
        end,
    })

    M.highlight_buffer(event.buf)
end

return M
