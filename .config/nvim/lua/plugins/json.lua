local function pretty_json()
    if vim.bo.filetype ~= "json" then
        vim.notify("Pretty JSON works only for json buffers", vim.log.levels.WARN)
        return
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, "\n")
    local ok, decoded = pcall(vim.json.decode, text)
    if not ok then
        vim.notify("Invalid JSON: " .. decoded, vim.log.levels.ERROR)
        return
    end

    local encoded = vim.json.encode(decoded)
    if not encoded then
        vim.notify("Failed to encode JSON", vim.log.levels.ERROR)
        return
    end

    local python = vim.fn.exepath("python3")
    if python == "" then
        python = vim.fn.exepath("python")
    end
    if python == "" then
        vim.notify("Python is required to pretty format JSON", vim.log.levels.ERROR)
        return
    end

    local formatted = vim.fn.system({ python, "-m", "json.tool" }, encoded)
    if vim.v.shell_error ~= 0 or formatted == "" then
        vim.notify("Failed to pretty format JSON", vim.log.levels.ERROR)
        return
    end

    local view = vim.fn.winsaveview()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.trim(formatted), "\n"))
    vim.fn.winrestview(view)
end

vim.keymap.set("n", "<leader>jp", pretty_json, { desc = "Pretty JSON" })
