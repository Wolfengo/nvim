local M = {}

local namespace = vim.api.nvim_create_namespace("UserPathLinks")
local highlight_group = "UserPathLink"
local resolved_cache = {}

local find_patterns = {
    "[%w%._%-/\\]+:%d+:%d+",
    "[%w%._%-/\\]+:%d+",
    "[%w%._%-/\\]+",
}

local function set_highlight()
    vim.api.nvim_set_hl(0, highlight_group, {
        fg = "#00bfff",
        underline = true,
        bold = true,
    })
end

set_highlight()

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UserPathLinkHighlight", { clear = true }),
    callback = set_highlight,
})

local function parse_from_line(line)
    local patterns = {
        "([%w%._%-]+[/\\][%w%._%-%/\\]+):(%d+):(%d+)",
        "([%w%._%-]+[/\\][%w%._%-%/\\]+):(%d+)",
        "([%w%._%-]+[/\\][%w%._%-%/\\]+)",
        "([%w%._%-]+%.[%w]+):(%d+):(%d+)",
        "([%w%._%-]+%.[%w]+):(%d+)",
        "([%w%._%-]+%.[%w]+)",
    }

    for _, item in ipairs(patterns) do
        local path, row, col = line:match(item)
        if path then
            return path, row, col
        end
    end
end

function M.resolve(path)
    if resolved_cache[path] ~= nil then
        return resolved_cache[path] or nil
    end

    local resolved = vim.fs.normalize(path)
    if vim.fn.filereadable(resolved) == 0 then
        resolved = vim.fs.normalize(vim.fn.getcwd() .. "/" .. path)
    end
    if vim.fn.filereadable(resolved) == 0 then
        resolved_cache[path] = false
        return nil
    end
    resolved_cache[path] = resolved
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

local function visible_range(bufnr)
    local wins = vim.fn.win_findbuf(bufnr)
    if #wins == 0 then
        return 0, math.min(vim.api.nvim_buf_line_count(bufnr) - 1, 300)
    end

    local top, bottom = vim.api.nvim_win_call(wins[1], function()
        return vim.fn.line("w0"), vim.fn.line("w$")
    end)

    local start_row = math.max((top or 1) - 21, 0)
    local end_row = math.min((bottom or 1) + 20, vim.api.nvim_buf_line_count(bufnr))
    return start_row, end_row - 1
end

function M.highlight_buffer(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local first_row, last_row = visible_range(bufnr)
    for row = first_row, last_row do
        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
        for _, pattern in ipairs(find_patterns) do
            local start = 1
            while true do
                local s, e = line:find(pattern, start)
                if not s then
                    break
                end
                local text = line:sub(s, e)
                local path = parse_from_line(text)
                if path and M.resolve(path) then
                    vim.api.nvim_buf_add_highlight(bufnr, namespace, highlight_group, row, s - 1, e)
                end
                start = e + 1
            end
        end
    end
end

function M.setup_buffer(event)
    local opts = { buffer = event.buf }
    vim.keymap.set("n", "gf", M.open_under_cursor, opts)
    vim.keymap.set("n", "<CR>", M.open_under_cursor, opts)

    local group = vim.api.nvim_create_augroup("UserPathLinks:" .. event.buf, { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "WinScrolled" }, {
        group = group,
        buffer = event.buf,
        callback = function()
            resolved_cache = {}
            M.highlight_buffer(event.buf)
        end,
    })

    M.highlight_buffer(event.buf)
end

return M
