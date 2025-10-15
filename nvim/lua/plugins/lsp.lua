return {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
        "mason.nvim",
        { "mason-org/mason-lspconfig.nvim", config = function() end },
    },
    opts = function()
        ---@class PluginLspOpts
        local ret = {
            -- options for vim.diagnostic.config()
            ---@type vim.diagnostic.Opts
            diagnostics = {
                underline = true,
                update_in_insert = false,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                    -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
                    -- prefix = "icons",
                },
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
                        [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
                        [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
                        [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
                    },
                },
            },
            -- Enable this to enable the builtin LSP inlay hints on Neovim.
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the inlay hints.
            inlay_hints = {
                enabled = true,
                exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
            },
            -- Enable this to enable the builtin LSP code lenses on Neovim.
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the code lenses.
            codelens = {
                enabled = false,
            },
            -- Enable this to enable the builtin LSP folding on Neovim.
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the folds.
            folds = {
                enabled = true,
            },
            -- add any global capabilities here
            capabilities = {
                workspace = {
                    fileOperations = {
                        didRename = true,
                        willRename = true,
                    },
                },
            },
            -- options for vim.lsp.buf.format
            -- `bufnr` and `filter` is handled by the LazyVim formatter,
            -- but can be also overridden when specified
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            -- LSP Server Settings
            ---@alias lazyvim.lsp.Config vim.lsp.Config|{mason?:boolean, enabled?:boolean}
            ---@type table<string, lazyvim.lsp.Config|boolean>
            servers = {
                lua_ls = {
                    -- mason = false, -- set to false if you don't want this server to be installed with mason
                    -- Use this to add any additional keymaps
                    -- for specific lsp servers
                    -- ---@type LazyKeysSpec[]
                    -- keys = {},
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            codeLens = {
                                enable = true,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            doc = {
                                privateName = { "^_" },
                            },
                            hint = {
                                enable = true,
                                setType = false,
                                paramType = true,
                                paramName = "Disable",
                                semicolon = "Disable",
                                arrayIndex = "Disable",
                            },
                        },
                    },
                },
                -- Ensure mason installs the server
                clangd = {
                    keys = {
                        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                    },
                    root_markers = {
                        "compile_commands.json",
                        "compile_flags.txt",
                        "configure.ac", -- AutoTools
                        "Makefile",
                        "configure.ac",
                        "configure.in",
                        "config.h.in",
                        "meson.build",
                        "meson_options.txt",
                        "build.ninja",
                        ".git",
                    },
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                    cmd = {
                        "clangd",
                        "--all-scopes-completion",
                        "--background-index",
                        "--clang-tidy",
                        "--compile_args_from=filesystem", -- lsp-> does not come from compie_commands.json
                        "--completion-parse=always",
                        "--completion-style=detailed",
                        "--cross-file-rename",
                        "--debug-origin",
                        "--enable-config", -- clangd 11+ supports reading from .clangd configuration file
                        "--fallback-style=Qt",
                        "--folding-ranges",
                        "--function-arg-placeholders",
                        "--header-insertion=iwyu",
                        "--pch-storage=memory", -- could also be disk
                        "--suggest-missing-includes",
                        "--limit-references=100",
                        "-j=20", -- number of workers
                        -- "--resource-dir="
                        "--log=error",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },
                -- Python
                ruff = {
                    cmd_env = { RUFF_TRACE = "messages" },
                    init_options = {
                        settings = {
                            logLevel = "error",
                        },
                    },
                    keys = {
                        {
                            "<leader>co",
                            LazyVim.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                    },
                },
                ruff_lsp = {
                    keys = {
                        {
                            "<leader>co",
                            LazyVim.lsp.action["source.organizeImports"],
                            desc = "Organize Imports",
                        },
                    },
                },
                -- Ansible
                ansiblels = {},
                -- Docker
                dockerls = {},
                docker_compose_language_service = {},
                -- Cmake
                neocmake = {},
            },
            -- you can do any additional lsp server setup here
            -- return true if you don't want this server to be setup with lspconfig
            ---@type table<string, fun(server:string, opts: vim.lsp.Config):boolean?>
            setup = {
                -- C++
                clangd = function(_, opts)
                    local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
                    require("clangd_extensions").setup(
                        vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts })
                    )
                    return false
                end,
            },
        }
        return ret
    end,
    ---@param opts PluginLspOpts
    config = vim.schedule_wrap(function(_, opts)
        -- setup autoformat
        LazyVim.format.register(LazyVim.lsp.formatter())

        -- setup keymaps
        LazyVim.lsp.on_attach(function(client, buffer)
            require("lazyvim.plugins.lsp.keymaps").on_attach(client, buffer)
        end)

        LazyVim.lsp.setup()
        LazyVim.lsp.on_dynamic_capability(require("lazyvim.plugins.lsp.keymaps").on_attach)

        -- inlay hints
        if opts.inlay_hints.enabled then
            LazyVim.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
                if
                    vim.api.nvim_buf_is_valid(buffer)
                    and vim.bo[buffer].buftype == ""
                    and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
                then
                    vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
                end
            end)
        end

        -- folds
        if opts.folds.enabled then
            LazyVim.lsp.on_supports_method("textDocument/foldingRange", function(client, buffer)
                if LazyVim.set_default("foldmethod", "expr") then
                    LazyVim.set_default("foldexpr", "v:lua.vim.lsp.foldexpr()")
                end
            end)
        end

        -- code lens
        if opts.codelens.enabled and vim.lsp.codelens then
            LazyVim.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
                vim.lsp.codelens.refresh()
                vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                    buffer = buffer,
                    callback = vim.lsp.codelens.refresh,
                })
            end)
        end

        -- diagnostics
        if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
            opts.diagnostics.virtual_text.prefix = function(diagnostic)
                local icons = LazyVim.config.icons.diagnostics
                for d, icon in pairs(icons) do
                    if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                        return icon
                    end
                end
                return "●"
            end
        end
        vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

        if opts.capabilities then
            vim.lsp.config("*", { capabilities = opts.capabilities })
        end

        -- get all the servers that are available through mason-lspconfig
        local have_mason = LazyVim.has("mason-lspconfig.nvim")
        local mason_all = have_mason
                and vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
            or {} --[[ @as string[] ]]

        ---@return boolean? exclude automatic setup
        local function configure(server)
            local sopts = opts.servers[server]
            sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts --[[@as lazyvim.lsp.Config]]
            if sopts.enabled == false then
                return true
            end

            local setup = opts.setup[server] or opts.setup["*"]
            if setup and setup(server, sopts) then
                return true -- lsp will be configured and enabled by the setup function
            end

            vim.lsp.config(server, sopts) -- configure the server

            -- manually enable if mason=false or if this is a server that cannot be installed with mason-lspconfig
            if sopts.mason == false or not vim.tbl_contains(mason_all, server) then
                vim.lsp.enable(server)
                return true
            end
        end

        local servers = vim.tbl_keys(opts.servers)
        local exclude = vim.tbl_filter(configure, servers)
        if have_mason then
            require("mason-lspconfig").setup({
                ensure_installed = vim.tbl_filter(function(server)
                    return not vim.tbl_contains(exclude, server)
                end, vim.list_extend(
                    servers,
                    LazyVim.opts("mason-lspconfig.nvim").ensure_installed or {}
                )),
                automatic_enable = { exclude = exclude },
            })
        end
    end),
}
