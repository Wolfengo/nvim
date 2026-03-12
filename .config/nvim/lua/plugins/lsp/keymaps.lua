local M = {}

function M.setup_diagnostics()
    vim.keymap.set('n', '<leader>lD', vim.diagnostic.open_float)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist)
    vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float)
    vim.keymap.set('n', '<leader>ln', vim.diagnostic.goto_next)
    vim.keymap.set('n', '<leader>lp', vim.diagnostic.goto_prev)
end

function M.setup_attach()
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        end,
    })
end

return M
