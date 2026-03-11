require('nvim-ts-autotag').setup()

vim.diagnostic.config({
    signs = true,
    underline = true,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "if_many",
    },
    virtual_text = {
        spacing = 5,
        severity = { min = vim.diagnostic.severity.WARN },
    },
    update_in_insert = false,
})
