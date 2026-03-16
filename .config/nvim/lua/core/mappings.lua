vim.g.mapleader = " "

local buffers = require("features.buffers")
local navigation = require("features.navigation")
local russian = require("features.russian")
local terminal = require("features.terminal")

local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
end

map('n', '<leader>e', ':Neotree focus<CR>')
map('n', '<leader>o', ':Neotree git_status float<CR>')

map('n', '<Tab>', ':BufferLineCycleNext<CR>')
map('n', '<s-Tab>', ':BufferLineCyclePrev<CR>')

map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<C-Left>', '<C-w>h')
map('n', '<C-Down>', '<C-w>j')
map('n', '<C-Up>', '<C-w>k')
map('n', '<C-Right>', '<C-w>l')
map('n', '<S-Up>', ':resize +3<CR>')
map('n', '<S-Down>', ':resize -3<CR>')
map('n', '<S-Left>', ':vertical resize -5<CR>')
map('n', '<S-Right>', ':vertical resize +5<CR>')

map('n', '<leader>w', ':w<CR>')
map('n', '<leader>x', ':BufferLinePickClose<CR>')
map('n', '<leader>X', ':BufferLineCloseRight<CR>')
map('n', '<leader>s', ':BufferLineSortByTabs<CR>')
map('n', 'ww', ':w<CR>')
map('n', 'qq', buffers.close_current)
map('n', '<M-j>', function() navigation.jump_syntax_block("next") end)
map('n', '<M-k>', function() navigation.jump_syntax_block("prev") end)
map('n', '<M-Down>', function() navigation.jump_syntax_block("next") end)
map('n', '<M-Up>', function() navigation.jump_syntax_block("prev") end)
map('n', '<M-Left>', function() navigation.jump_line_segment("left") end)
map('n', '<M-Right>', function() navigation.jump_line_segment("right") end)
map('i', 'jj', '<Esc>')
map('n', '<leader>h', ':nohlsearch<CR>')

map('n', '<C-\\>', function() terminal.toggle(terminal.ids.main, "bottom") end)
map('n', '<leader>t1', function() terminal.toggle(terminal.ids.main, "bottom") end)
map('n', '<leader>t2', function() terminal.toggle(terminal.ids.bottom_2, "bottom") end)
map('n', '<leader>t3', function() terminal.toggle(terminal.ids.bottom_3, "bottom") end)
map('n', '<leader>t4', function() terminal.toggle(terminal.ids.float, "float") end)

russian.apply_general(map, terminal)
