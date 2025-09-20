local cmp = require 'cmp'

-- Настройка autocompletion
cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- Для пользователей vsnip
            -- require('luasnip').lsp_expand(args.body) -- Для пользователей luasnip
        end
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered()
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({select = true}),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, {"i", "s"}),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, {"i", "s"})
    }),
    sources = cmp.config.sources({
        {name = 'nvim_lsp'}, {name = 'vsnip'} -- Для vsnip пользователей
    }, {{name = 'buffer'}, {name = 'nvim_lsp_signature_help'}})
})

-- Конфигурация для конкретных файлов
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        {name = 'cmp_git'}
    }, {{name = 'buffer'}})
})

-- Использование buffer source для '/' и '?'
cmp.setup.cmdline({'/', '?'}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {{name = 'buffer'}}
})

-- Использование cmdline & path source для ':'
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}})
})

-- 🔧 ОБНОВЛЕННАЯ ЧАСТЬ: Настройка LSP с использованием нового API
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Используем новый синтаксис vim.lsp.config вместо require('lspconfig')
vim.lsp.config('ts_ls', {
    capabilities = capabilities,
    -- Дополнительные настройки для TypeScript сервера
    settings = {
        typescript = {
            completions = {
                completeFunctionCalls = true
            }
        }
    }
})

-- Включаем настроенный сервер
vim.lsp.enable('ts_ls')
