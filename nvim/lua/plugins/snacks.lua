return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        -- Open git log in vertical view
        {
            "<leader>gl",
            function()
                Snacks.picker.git_log({
                    finder = "git_log",
                    format = "git_log",
                    preview = "git_show",
                    confirm = "git_checkout",
                    layout = "vertical",
                })
            end,
            desc = "Git Log",
        },
        -- List git branches with Snacks_picker to quickly switch to a new branch
        {
            "<M-b>",
            function()
                Snacks.picker.git_branches({
                    layout = "select",
                })
            end,
            desc = "Branches",
        },
        -- Used in LazyVim to view the different keymaps, this by default is
        -- configured as <leader>sk but I run it too often
        {
            -- Sometimes I need to see if a keymap is already taken or not
            "<M-k>",
            function()
                Snacks.picker.keymaps({
                    layout = "vertical",
                })
            end,
            desc = "Keymaps",
        },
        -- File picker
        {
            "<leader><space>",
            function()
                Snacks.picker.files({
                    finder = "files",
                    format = "file",
                    show_empty = true,
                    supports_live = true,
                    -- In case you want to override the layout for this keymap
                    -- layout = "vscode",
                })
            end,
            desc = "Find Files",
        },
        -- Navigate buffers
        {
            "<M-h>",
            function()
                Snacks.picker.buffers({
                    -- I always want my buffers picker to start in normal mode
                    on_show = function()
                        vim.cmd.stopinsert()
                    end,
                    finder = "buffers",
                    format = "buffer",
                    hidden = false,
                    unloaded = true,
                    current = true,
                    sort_lastused = true,
                    win = {
                        input = {
                            keys = {
                                ["d"] = "bufdelete",
                            },
                        },
                        list = { keys = { ["d"] = "bufdelete" } },
                    },
                    -- In case you want to override the layout for this keymap
                    -- layout = "ivy",
                })
            end,
            desc = "[P]Snacks picker buffers",
        },
    },
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        bigfile = {
            enabled = true,
            notify = true, -- show notification when big file detected
            size = 10 * 1024 * 1024, -- 10MB
            line_length = 1000, -- average line length (useful for minified files)
            -- Enable or disable features when big file detected
            ---@param ctx {buf: number, ft:string}
            setup = function(ctx)
                if vim.fn.exists(":NoMatchParen") ~= 0 then
                    vim.cmd([[NoMatchParen]])
                end
                Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
                vim.b.minianimate_disable = true
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(ctx.buf) then
                        vim.bo[ctx.buf].syntax = ctx.ft
                    end
                end)
            end,
        },

        picker = {
            enabled = true,
            -- My ~/github/dotfiles-latest/neovim/lazyvim/lua/config/keymaps.lua
            -- file was always showing at the top, I needed a way to decrease its
            -- score, in frecency you could use :FrecencyDelete to delete a file
            -- from the database, here you can decrease it's score
            transform = function(item)
                if not item.file then
                    return item
                end
                -- Demote the "lazyvim" keymaps file:
                if item.file:match("lazyvim/lua/config/keymaps%.lua") then
                    item.score_add = (item.score_add or 0) - 30
                end
                -- Boost the "neobean" keymaps file:
                -- if item.file:match("neobean/lua/config/keymaps%.lua") then
                --   item.score_add = (item.score_add or 0) + 100
                -- end
                return item
            end,
            -- In case you want to make sure that the score manipulation above works
            -- or if you want to check the score of each file
            debug = {
                scores = false, -- show scores in the list
            },
            matcher = {
                frecency = true,
            },
            win = {
                input = {
                    keys = {
                        -- to close the picker on ESC instead of going to normal mode,
                        -- add the following keymap to your config
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                        -- I'm used to scrolling like this in LazyGit
                        ["J"] = { "preview_scroll_down", mode = { "i", "n" } },
                        ["K"] = { "preview_scroll_up", mode = { "i", "n" } },
                        ["H"] = { "preview_scroll_left", mode = { "i", "n" } },
                        ["L"] = { "preview_scroll_right", mode = { "i", "n" } },
                        ["<a-c>"] = {
                            "toggle_cwd",
                            mode = { "n", "i" },
                        },
                    },
                },
            },
            formatters = {
                file = {
                    filename_first = true, -- display filename before the file path
                    --        truncate = 80,
                },
            },
            actions = {
                ---@param p snacks.Picker
                toggle_cwd = function(p)
                    local root = LazyVim.root({ buf = p.input.filter.current_buf, normalize = true })
                    local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
                    local current = p:cwd()
                    p:set_cwd(current == root and cwd or root)
                    p:find()
                end,
            },
            hidden = false,
            ignored = false,
        },
        -- Folke pointed me to the snacks docs
        -- https://github.com/LazyVim/LazyVim/discussions/4251#discussioncomment-11198069
        -- Here's the lazygit snak docs
        -- https://github.com/folke/snacks.nvim/blob/main/docs/lazygit.md
        lazygit = {
            theme = {
                selectedLineBgColor = { bg = "CursorLine" },
            },
            -- With this I make lazygit to use the entire screen, because by default there's
            -- "padding" added around the sides
            -- https://github.com/folke/snacks.nvim/issues/719
            win = {
                -- -- The first option was to use the "dashboard" style, which uses a
                -- -- 0 height and width, see the styles documentation
                -- -- https://github.com/folke/snacks.nvim/blob/main/docs/styles.md
                -- style = "dashboard",
                width = 0,
                height = 0,
            },
        },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        dashboard = {
            preset = {
                pick = nil,
                ---@type snacks.dashboard.Item[]
                keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                    { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                    {
                        icon = " ",
                        key = "g",
                        desc = "Find Text",
                        action = ":lua Snacks.dashboard.pick('live_grep')",
                    },
                    {
                        icon = " ",
                        key = "r",
                        desc = "Recent Files",
                        action = ":lua Snacks.dashboard.pick('oldfiles')",
                    },
                    {
                        icon = " ",
                        key = "c",
                        desc = "Config",
                        action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
                    },
                    { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                    {
                        icon = "󰒲 ",
                        key = "l",
                        desc = "Lazy",
                        action = ":Lazy",
                        enabled = package.loaded.lazy ~= nil,
                    },
                    { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                },
                header = [[
                                                      
               ████ ██████           █████      ██
              ███████████             █████ 
              █████████ ███████████████████ ███   ███████████
             █████████  ███    █████████████ █████ ██████████████
            █████████ ██████████ █████████ █████ █████ ████ █████
          ███████████ ███    ███ █████████ █████ █████ ████ █████
         ██████  █████████████████████ ████ █████ █████ ████ ██████
      ]],
            },
            sections = {
                { section = "header" },
                {
                    section = "keys",
                    indent = 1,
                    padding = 1,
                },
                { section = "recent_files", icon = " ", title = "Recent Files", indent = 3, padding = 2 },
                { section = "startup" },
            },
        },
        explorer = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        git = { enabled = true },
        gitbrowse = { enabled = true },
    },
}
