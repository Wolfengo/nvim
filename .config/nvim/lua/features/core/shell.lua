local M = {}

function M.apply()
    local preferred_shell = vim.env.SHELL
    if preferred_shell and vim.fn.executable(preferred_shell) == 1 then
        vim.opt.shell = preferred_shell
        return
    end

    if vim.fn.executable("/usr/bin/zsh") == 1 then
        vim.opt.shell = "/usr/bin/zsh"
        return
    end

    if vim.fn.executable("/bin/bash") == 1 then
        vim.opt.shell = "/bin/bash"
    end
end

return M
