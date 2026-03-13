local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    { "phaazon/hop.nvim" },
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v2.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "s1n7ax/nvim-window-picker",
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = vim.fn.has("nvim-0.11") == 1 and "main" or "master",
      build = ":TSUpdate",
      lazy = false,
    },
    {
      "neovim/nvim-lspconfig",
    },
    { "joshdick/onedark.vim" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/nvim-cmp" },
    { "williamboman/mason.nvim" },
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
      "nvimtools/none-ls.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
    },
    { "windwp/nvim-autopairs" },
    { "windwp/nvim-ts-autotag" },
    {
      "akinsho/bufferline.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    { "terrortylor/nvim-comment" },
    { "lewis6991/gitsigns.nvim" },
    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
      },
      ft = { "markdown" },
    },
    {
      "3rd/image.nvim",
      cond = function()
        local term = vim.env.TERM or ""
        return term:find("kitty", 1, true) ~= nil and vim.fn.executable("magick") == 1
      end,
      build = false,
    },
  },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = true },
})
