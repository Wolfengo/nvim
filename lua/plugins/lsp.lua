-- Установите общие возможности для LSP (если используете nvim-cmp)
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Замените require('lspconfig') на прямое использование vim.lsp.config
-- Включите необходимые серверы с их настройками
vim.lsp.config('pyright', {})
vim.lsp.config('ts_ls', {})  -- Исправлено имя сервера!
vim.lsp.config('prismals', {})
vim.lsp.config('cssls', {
    -- capabilities = capabilities  -- Раскомментируйте, если используете nvim-cmp
})
vim.lsp.config('golangci_lint_ls', {})
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true,
        experimental = {
          enable = true,
        },
      },
    },
  },
})

-- Включите все настроенные серверы
vim.lsp.enable({'pyright', 'ts_ls', 'prismals', 'cssls', 'golangci_lint_ls', 'rust_analyzer'})

-- Глобальные mapping'и для диагностик остаются без изменений
vim.keymap.set('n', '<leader>lD', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist)

-- Autocommand для LspAttach также остается без изменений
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- ... ваш текущий код обработки LspAttach
  end
})
