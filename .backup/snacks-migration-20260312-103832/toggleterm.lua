require("toggleterm").setup({
    open_mapping = [[<c-\>]],
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_mode = true,
    direction = "horizontal",
    shade_terminals = false,
})

local Terminal = require("toggleterm.terminal").Terminal
local terminals = {
    [1] = Terminal:new({ count = 1, hidden = true, direction = "horizontal" }),
    [2] = Terminal:new({ count = 2, hidden = true, direction = "horizontal" }),
    [3] = Terminal:new({ count = 3, hidden = true, direction = "horizontal" }),
    [4] = Terminal:new({ count = 4, hidden = true, direction = "horizontal" }),
}

function _G.toggle_numbered_terminal(index)
    local terminal = terminals[index]
    if terminal then
        terminal:toggle()
    end
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

function _G.set_terminal_keymaps()
    local opts = {buffer = 0}
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    vim.keymap.set('t', '<leader>tt', [[<Cmd>ToggleTerm<CR>]], opts)
    vim.keymap.set('t', '<leader>c', [[<C-\><C-n><C-w>p]], opts)
    vim.keymap.set('n', 'gf', open_terminal_path, opts)
    vim.keymap.set('t', '<leader>1', [[<Cmd>lua toggle_numbered_terminal(1)<CR>]], opts)
    vim.keymap.set('t', '<leader>2', [[<Cmd>lua toggle_numbered_terminal(2)<CR>]], opts)
    vim.keymap.set('t', '<leader>3', [[<Cmd>lua toggle_numbered_terminal(3)<CR>]], opts)
    vim.keymap.set('t', '<leader>4', [[<Cmd>lua toggle_numbered_terminal(4)<CR>]], opts)
end

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*toggleterm#*",
    callback = function()
        set_terminal_keymaps()
    end,
})
