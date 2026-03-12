local M = {}

local function setup_osc52()
    local osc52_cache = { ["+"] = "", ["*"] = "" }

    local function osc52_copy(lines, regtype, register)
        local text = table.concat(lines, "\n")
        if regtype == "V" then
            text = text .. "\n"
        end

        osc52_cache[register] = text

        local sequence = string.format("\x1b]52;c;%s\x07", vim.base64.encode(text))
        if vim.env.TMUX then
            sequence = string.format("\x1bPtmux;\x1b%s\x1b\\", sequence)
        end

        io.stdout:write(sequence)
        io.stdout:flush()
    end

    vim.g.clipboard = {
        name = "osc52-ssh",
        copy = {
            ["+"] = function(lines, regtype)
                osc52_copy(lines, regtype, "+")
            end,
            ["*"] = function(lines, regtype)
                osc52_copy(lines, regtype, "*")
            end,
        },
        paste = {
            ["+"] = function()
                return vim.split(osc52_cache["+"] or "", "\n"), vim.fn.getregtype("+")
            end,
            ["*"] = function()
                return vim.split(osc52_cache["*"] or "", "\n"), vim.fn.getregtype("*")
            end,
        },
    }
end

function M.apply()
    vim.opt.clipboard = "unnamedplus"

    if vim.env.SSH_CONNECTION and not vim.env.DISPLAY and not vim.env.WAYLAND_DISPLAY then
        setup_osc52()
    end
end

return M
