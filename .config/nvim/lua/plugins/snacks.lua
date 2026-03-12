local ok, snacks = pcall(require, "snacks")
if not ok then
    return
end

snacks.setup({
    terminal = {},
})

local function terminal_win(position)
    if position == "float" then
        return {
            style = "terminal",
            position = "float",
            border = "rounded",
        }
    end

    if position == "right" then
        return {
            style = "terminal",
            position = "right",
            width = 0.4,
        }
    end

    return {
        style = "terminal",
        position = "bottom",
        height = 0.3,
    }
end

function _G.toggle_snacks_terminal(count, position)
    snacks.terminal.toggle(nil, {
        count = count,
        cwd = vim.fn.getcwd(),
        start_insert = true,
        auto_insert = false,
        win = terminal_win(position),
    })
end

local function open_terminal_path()
    local line = vim.api.nvim_get_current_line()
    local patterns = {
        "([%w%._%-%/\\]+):(%d+):(%d+)",
        "([%w%._%-%/\\]+):(%d+)",
    }

    local path, row, col
    for _, pattern in ipairs(patterns) do
        path, row, col = line:match(pattern)
        if path then
            break
        end
    end

    if not path then
        return
    end

    local resolved = vim.fs.normalize(path)
    if vim.fn.filereadable(resolved) == 0 then
        resolved = vim.fs.normalize(vim.fn.getcwd() .. "/" .. path)
    end

    if vim.fn.filereadable(resolved) == 0 then
        vim.notify("File not found: " .. path, vim.log.levels.WARN)
        return
    end

    vim.cmd("edit " .. vim.fn.fnameescape(resolved))
    vim.api.nvim_win_set_cursor(0, { tonumber(row), math.max((tonumber(col) or 1) - 1, 0) })
end

local function set_terminal_keymaps(event)
    local opts = { buffer = event.buf }
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    vim.keymap.set('t', '<C-\\>', function() toggle_snacks_terminal(1, "bottom") end, opts)
    vim.keymap.set('t', '<leader>tt', function() toggle_snacks_terminal(1, "bottom") end, opts)
    vim.keymap.set('t', '<leader>tf', function() toggle_snacks_terminal(2, "float") end, opts)
    vim.keymap.set('t', '<leader>th', function() toggle_snacks_terminal(1, "bottom") end, opts)
    vim.keymap.set('t', '<leader>tv', function() toggle_snacks_terminal(3, "right") end, opts)
    vim.keymap.set('t', '<leader>1', function() toggle_snacks_terminal(1, "bottom") end, opts)
    vim.keymap.set('t', '<leader>2', function() toggle_snacks_terminal(2, "bottom") end, opts)
    vim.keymap.set('t', '<leader>3', function() toggle_snacks_terminal(3, "bottom") end, opts)
    vim.keymap.set('t', '<leader>4', function() toggle_snacks_terminal(4, "bottom") end, opts)
    vim.keymap.set('t', '<leader>c', [[<C-\><C-n><C-w>p]], opts)
    vim.keymap.set('n', 'gf', open_terminal_path, opts)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_terminal",
    callback = set_terminal_keymaps,
})
