local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")
local python = require("features.python")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.mypy.with({
            dynamic_command = helpers.cache.by_bufnr(function(params)
                return python.project_executable(params.bufname, "mypy")
            end),
        }),
        null_ls.builtins.formatting.prettierd.with({
            filetypes = {
                "javascript", "javascriptreact",
                "typescript", "typescriptreact",
                "json", "jsonc", "yaml", "markdown", "markdown.mdx",
                "graphql", "html", "css", "scss", "less",
            },
        }),
        null_ls.builtins.formatting.stylua,
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
                            return c.name == "null-ls" or c.name == "none-ls"
                        end,
                    })
                end,
            })
        end
    end,
})
