local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
local lspconfig_util = require("lspconfig.util")

local function find_upward(startpath, targets)
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

local function find_venv_python(startpath)
  return find_upward(startpath, {
    ".venv/bin/python",
    "venv/bin/python",
  })
end

local servers = {
  pyright = {
    root_dir = function(fname)
      return lspconfig_util.root_pattern(
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git"
      )(fname)
    end,
    before_init = function(_, config)
      local python_path = find_venv_python(config.root_dir)
      if python_path then
        local venv_dir = vim.fs.dirname(vim.fs.dirname(python_path))
        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
          python = {
            pythonPath = python_path,
            venvPath = vim.fs.dirname(venv_dir),
            venv = vim.fs.basename(venv_dir),
          },
        })
      end
    end,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly",
        },
      },
    },
  },
  ts_ls = {
    settings = {
      typescript = {
        completions = {
          completeFunctionCalls = true,
        },
      },
    },
  },
  prismals = {},
  cssls = {},
  golangci_lint_ls = {},
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        diagnostics = {
          enable = true,
          experimental = {
            enable = true,
          },
        },
      },
    },
  },
}

local function setup_server(server, config)
  if vim.lsp.config and vim.lsp.enable then
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
    return
  end

  require("lspconfig")[server].setup(config)
end

for server, config in pairs(servers) do
  config.capabilities = capabilities
  setup_server(server, config)
end

vim.keymap.set('n', '<leader>lD', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist)
vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>ln', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>lp', vim.diagnostic.goto_prev)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  end
})
