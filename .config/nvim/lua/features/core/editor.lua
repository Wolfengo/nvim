local M = {}

function M.apply()
    vim.opt.formatoptions = "qrn1"
    vim.opt.showmode = false
    vim.opt.updatetime = 300
    vim.opt.timeoutlen = 500
    vim.opt.scrolloff = 8
    vim.opt.wrap = false
    vim.opt.virtualedit = "block"
    vim.opt.undofile = true
    vim.opt.shortmess:append("c")

    vim.opt.expandtab = false
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.smartindent = true
end

return M
