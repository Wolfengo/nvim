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

treesitter.setup({})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("UserTreesitterHighlight", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
