-- ~/.config/nvim/lua/plugins/nullls.lua
local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
    sources = {
        -- Python
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.mypy,

        -- JavaScript / TypeScript / React
        null_ls.builtins.formatting.prettierd.with({
            filetypes = {
                "javascript", "javascriptreact",
                "typescript", "typescriptreact",
                "json", "jsonc", "yaml", "markdown", "markdown.mdx",
                "graphql", "html", "css", "scss", "less",
            },
        }),
        null_ls.builtins.diagnostics.eslint, -- ⚡️ теперь так

        -- Lua
        null_ls.builtins.formatting.stylua,

        -- Rust
        null_ls.builtins.formatting.rustfmt,
    },

    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({
                        bufnr = bufnr,
                        filter = function(c)
                            return c.name == "null-ls"
                        end,
                    })
                end,
            })
        end
    end,
})
