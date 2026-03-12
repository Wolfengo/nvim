local ok, snacks = pcall(require, "snacks")
if not ok then
    return
end

local terminal = require("features.terminal")

snacks.setup({
    terminal = {},
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_terminal",
    callback = terminal.setup_keymaps,
})
