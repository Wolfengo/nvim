local languages = {
  "c",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "markdown",
  "markdown_inline",
  "python",
  "tsx",
  "javascript",
  "rust",
}

local ok_legacy, legacy_configs = pcall(require, "nvim-treesitter.configs")
if ok_legacy then
  legacy_configs.setup({
    ensure_installed = languages,
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
    },
  })
  return
end

local ok_modern, treesitter = pcall(require, "nvim-treesitter")
if not ok_modern then
  vim.notify("nvim-treesitter is unavailable", vim.log.levels.WARN)
  return
end

local function ensure_modern_parsers()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  if vim.fn.executable("tree-sitter") ~= 1 then
    vim.notify(
      "tree-sitter CLI is missing; run ~/.dotfiles/nvim/install-local.sh --dev-tools --nvim-bootstrap",
      vim.log.levels.WARN
    )
    return
  end

  local installed = {}
  for _, lang in ipairs(treesitter.get_installed()) do
    installed[lang] = true
  end

  local missing = {}
  for _, lang in ipairs(languages) do
    if not installed[lang] then
      table.insert(missing, lang)
    end
  end

  if #missing > 0 then
    pcall(function()
      treesitter.install(missing)
    end)
  end
end

treesitter.setup({})

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("UserTreesitterInstall", { clear = true }),
  once = true,
  callback = ensure_modern_parsers,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitterHighlight", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
