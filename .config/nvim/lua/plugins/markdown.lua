local ok, render_markdown = pcall(require, "render-markdown")
if ok then
    render_markdown.setup({
        file_types = { "markdown" },
        render_modes = true,
        heading = {
            enabled = true,
            sign = false,
        },
        code = {
            sign = false,
            width = "block",
        },
        bullet = {
            enabled = true,
        },
        checkbox = {
            enabled = true,
        },
    })
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    group = vim.api.nvim_create_augroup("UserMarkdownReading", { clear = true }),
    callback = function()
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.conceallevel = 0
    end,
})
