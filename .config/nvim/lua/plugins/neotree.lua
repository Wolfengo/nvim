require("neo-tree").setup({
    filesystem = {
        filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
        },
    },
})

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("NeoTreeAutoOpen", { clear = true }),
    callback = function()
        if vim.fn.argc() == 0 and not vim.g.started_by_firenvim then
            vim.cmd("Neotree focus")
        end
    end,
})
