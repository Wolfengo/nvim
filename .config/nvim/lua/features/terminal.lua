local M = {}
local paths = require("features.paths")

M.ids = {
    main = 1,
    float = 4,
    right = 13,
    bottom_2 = 2,
    bottom_3 = 3,
}

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

function M.toggle(count, position)
    local ok, snacks = pcall(require, "snacks")
    if not ok then
        return
    end

    snacks.terminal.toggle(nil, {
        count = count,
        cwd = vim.fn.getcwd(),
        start_insert = true,
        auto_insert = false,
        win = terminal_win(position),
    })
end

function M.setup_keymaps(event)
    local opts = { buffer = event.buf }
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-Left>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-Down>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-Up>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-Right>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<S-Up>', [[<C-\><C-n><Cmd>resize +3<CR>]], opts)
    vim.keymap.set('t', '<S-Down>', [[<C-\><C-n><Cmd>resize -3<CR>]], opts)
    vim.keymap.set('t', '<S-Left>', [[<C-\><C-n><Cmd>vertical resize -5<CR>]], opts)
    vim.keymap.set('t', '<S-Right>', [[<C-\><C-n><Cmd>vertical resize +5<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    vim.keymap.set('t', '<C-\\>', function() M.toggle(M.ids.main, "bottom") end, opts)
    vim.keymap.set('t', '<leader>tt', function() M.toggle(M.ids.main, "bottom") end, opts)
    vim.keymap.set('t', '<leader>tf', function() M.toggle(M.ids.float, "float") end, opts)
    vim.keymap.set('t', '<leader>th', function() M.toggle(M.ids.main, "bottom") end, opts)
    vim.keymap.set('t', '<leader>tv', function() M.toggle(M.ids.right, "right") end, opts)
    vim.keymap.set('t', '<leader>1', function() M.toggle(M.ids.main, "bottom") end, opts)
    vim.keymap.set('t', '<leader>2', function() M.toggle(M.ids.bottom_2, "bottom") end, opts)
    vim.keymap.set('t', '<leader>3', function() M.toggle(M.ids.bottom_3, "bottom") end, opts)
    vim.keymap.set('t', '<leader>4', function() M.toggle(M.ids.float, "float") end, opts)
    vim.keymap.set('t', '<leader>ее', function() M.toggle(M.ids.main, "bottom") end, opts)
    vim.keymap.set('t', '<leader>еа', function() M.toggle(M.ids.float, "float") end, opts)
    vim.keymap.set('t', '<leader>ер', function() M.toggle(M.ids.main, "bottom") end, opts)
    vim.keymap.set('t', '<leader>ем', function() M.toggle(M.ids.right, "right") end, opts)
    paths.setup_buffer(event)
end

return M
