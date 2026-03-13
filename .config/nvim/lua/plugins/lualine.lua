local colors = {
  blue = "#80a0ff",
  cyan = "#79dac8",
  black = "#080808",
  white = "#c6c6c6",
  red = "#ff5189",
  violet = "#d183e8",
  grey = "#303030",
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.violet },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.black, bg = colors.black },
  },
  insert = { a = { fg = colors.black, bg = colors.blue } },
  visual = { a = { fg = colors.black, bg = colors.cyan } },
  replace = { a = { fg = colors.black, bg = colors.red } },
  inactive = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.black, bg = colors.black },
  },
}

local layout_cache = "lang --"

local function current_input_layout()
  if vim.env.SSH_CONNECTION and not vim.env.DISPLAY and not vim.env.WAYLAND_DISPLAY then
    return ""
  end

  if vim.fn.executable("xkb-switch") == 1 then
    local layout = vim.trim(vim.fn.system("xkb-switch"))
    if layout ~= "" then
      return string.upper(layout:sub(1, 2))
    end
  end

  if vim.fn.executable("setxkbmap") == 1 and vim.env.DISPLAY then
    local output = vim.fn.system("setxkbmap -query")
    local layout = output:match("layout:%s*([%w,%-_]+)")
    if layout and layout ~= "" then
      return string.upper(vim.split(layout, ",")[1]:sub(1, 2))
    end
  end

  return ""
end

local function refresh_input_layout()
  local layout = current_input_layout()
  if layout == "" then
    layout_cache = "lang --"
    return
  end
  layout_cache = "lang " .. layout
end

local function current_input_layout_label()
  return layout_cache
end

local function project_file_path()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return "[No Name]"
  end

  local cwd = vim.fn.getcwd()
  local cwd_path = vim.fs.relpath(cwd, file)
  if cwd_path then
    return cwd_path
  end

  local root = vim.fs.root(file, {
    ".git",
    "pyproject.toml",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "Makefile",
  })

  if root then
    return vim.fs.relpath(root, file) or vim.fn.fnamemodify(file, ":.")
  end

  return vim.fn.fnamemodify(file, ":.")
end

refresh_input_layout()

vim.api.nvim_create_autocmd({ "FocusGained", "InsertLeave", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("UserInputLayoutRefresh", { clear = true }),
  callback = function()
    refresh_input_layout()
    pcall(function()
      require("lualine").refresh()
    end)
  end,
})

require("lualine").setup({
  options = {
    theme = bubbles_theme,
    component_separators = "|",
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
    lualine_b = { project_file_path, "branch" },
    lualine_c = { "fileformat" },
    lualine_x = {},
    lualine_y = {
      current_input_layout_label,
      "filetype",
      "progress",
    },
    lualine_z = {
      { "location", separator = { right = "" }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { project_file_path },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {},
  extensions = {},
})

vim.cmd([[
augroup lualine_augroup
    autocmd!
    autocmd User LspProgressStatusUpdated lua require("lualine").refresh()
augroup END
]])
