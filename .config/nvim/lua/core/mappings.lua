vim.g.mapleader = " "

local function jump_syntax_block(direction)
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then
        vim.cmd(direction == "next" and "normal! }" or "normal! {")
        return
    end

    local sibling_getter = direction == "next" and "next_named_sibling" or "prev_named_sibling"

    while node do
        local sibling = node[sibling_getter] and node[sibling_getter](node)
        if sibling then
            local row = sibling:range()
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
            return
        end
        node = node:parent()
    end

    vim.cmd(direction == "next" and "normal! }" or "normal! {")
end

vim.keymap.set('n', '<leader>e', ':Neotree focus<CR>')
vim.keymap.set('n', '<leader>o', ':Neotree git_status float<CR>')

vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>')
vim.keymap.set('n', '<s-Tab>', ':BufferLineCyclePrev<CR>')

vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader>x', ':BufferLinePickClose<CR>')
vim.keymap.set('n', '<leader>X', ':BufferLineCloseRight<CR>')
vim.keymap.set('n', '<leader>s', ':BufferLineSortByTabs<CR>')
vim.keymap.set('n', '<M-j>', function() jump_syntax_block("next") end)
vim.keymap.set('n', '<M-k>', function() jump_syntax_block("prev") end)
vim.keymap.set('i', 'jj', '<Esc>')
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')

vim.keymap.set('n', '<leader>tt', ':ToggleTerm<CR>')
vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<CR>')
vim.keymap.set('n', '<leader>th', ':ToggleTerm direction=horizontal<CR>')
vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical size=40<CR>')
vim.keymap.set('n', '<leader>c', '<C-w>p')
