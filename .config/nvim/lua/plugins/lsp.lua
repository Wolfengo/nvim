local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
local keymaps = require("plugins.lsp.keymaps")
local servers = require("plugins.lsp.servers")

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

keymaps.setup_diagnostics()
keymaps.setup_attach()
