local M = {}

function M.find_upward(startpath, targets)
    if not startpath or startpath == "" then
        return nil
    end

    local dir = vim.fs.dirname(startpath)
    return vim.fs.find(targets, {
        path = dir,
        upward = true,
        stop = vim.loop.os_homedir(),
    })[1]
end

function M.find_venv_python(startpath)
    return M.find_upward(startpath, {
        ".venv/bin/python",
        "venv/bin/python",
    })
end

function M.project_executable(startpath, command)
    return M.find_upward(startpath, {
        ".venv/bin/" .. command,
        "venv/bin/" .. command,
    }) or command
end

return M
