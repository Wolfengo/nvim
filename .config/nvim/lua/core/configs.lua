vim.wo.number = true
vim.wo.relativenumber = true

vim.opt.formatoptions = "qrn1"
vim.opt.showmode = false
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.wo.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.wo.linebreak = true
vim.opt.virtualedit = "block"
vim.opt.undofile = true
local preferred_shell = vim.env.SHELL
if preferred_shell and vim.fn.executable(preferred_shell) == 1 then
  vim.opt.shell = preferred_shell
elseif vim.fn.executable("/usr/bin/zsh") == 1 then
  vim.opt.shell = "/usr/bin/zsh"
elseif vim.fn.executable("/bin/bash") == 1 then
  vim.opt.shell = "/bin/bash"
end

vim.opt.mouse = "a"
vim.opt.mousefocus = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.clipboard = "unnamedplus"

if vim.env.SSH_CONNECTION and not vim.env.DISPLAY and not vim.env.WAYLAND_DISPLAY then
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

vim.opt.shortmess:append("c")

vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

vim.opt.fillchars = {
    vert = "│",
    fold = "⠀",
    eob = " ",
    msgsep = "‾",
    foldopen = "▾",
    foldsep = "│",
    foldclose = "▸"
}

vim.cmd([[highlight clear LineNr]])
vim.cmd([[highlight clear SignColumn]])
