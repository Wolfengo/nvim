local lspconfig_util = require("lspconfig.util")
local python = require("features.python")

return {
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
            local python_path = python.find_venv_python(config.root_dir)
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
