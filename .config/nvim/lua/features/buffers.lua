local M = {}

function M.close_current()
    local current = vim.api.nvim_get_current_buf()
    local listed = vim.tbl_filter(function(buf)
        return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())

    if #listed <= 1 then
        vim.cmd("enew")
        vim.cmd("bdelete " .. current)
        return
    end

    local alternate = vim.fn.bufnr("#")
    if alternate > 0 and vim.api.nvim_buf_is_loaded(alternate) and vim.bo[alternate].buflisted then
        vim.api.nvim_set_current_buf(alternate)
    else
        vim.cmd("bnext")
        if vim.api.nvim_get_current_buf() == current then
            vim.cmd("bprevious")
        end
    end

    vim.cmd("bdelete " .. current)
end

return M
