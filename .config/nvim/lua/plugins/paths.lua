local paths = require("features.paths")

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserPathLinksBuffers", { clear = true }),
    pattern = {
        "log",
        "checkhealth",
    },
    callback = paths.setup_buffer,
})
