local M = {}

function M.apply()
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.signcolumn = "yes"
    vim.opt.linebreak = true
    vim.opt.mouse = "a"
    vim.opt.mousefocus = true
    vim.opt.splitbelow = true
    vim.opt.splitright = true

    vim.opt.fillchars = {
        vert = "│",
        fold = "⠀",
        eob = " ",
        msgsep = "‾",
        foldopen = "▾",
        foldsep = "│",
        foldclose = "▸",
    }

    vim.cmd([[highlight clear LineNr]])
    vim.cmd([[highlight clear SignColumn]])
end

return M
