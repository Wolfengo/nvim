require("toggleterm").setup({
    open_mapping = [[<c-\>]],
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_mode = true,
    direction = "horizontal",
    shade_terminals = false,
})

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
end

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*",
    callback = function()
        set_terminal_keymaps()
    end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "term://*toggleterm#*",
    callback = function()
        vim.cmd("startinsert")
    end,
})
