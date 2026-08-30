local lazySpecs = {
    -- pretty notifications
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        config = function()
            require 'noice'.setup({
                messages = {
                    -- NOTE: If you enable messages, then the cmdline is enabled automatically.
                    -- This is a current Neovim limitation.
                    enabled = true,              -- enables the Noice messages UI
                    view = "mini",               -- default view for messages
                    view_error = "mini",         -- view for errors
                    view_warn = "mini",          -- view for warnings
                    view_history = "messages",   -- view for :messages
                    view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
                }

            })
        end
    },
    {
        'fei6409/log-highlight.nvim',
        config = function()
            require('log-highlight').setup {}
        end,
    },
    {
        'nanotee/zoxide.vim'
    },
    {
        'pd-nvim', -- TODO: needs meson + codelldb
        dependencies = {
          "folke/which-key.nvim",
          "nvim-neotest/nvim-nio" ,
          'nvim-telescope/telescope.nvim',
          'rcarriga/nvim-dap-ui',
          {
            "nvim-telescope/telescope-live-grep-args.nvim",
            -- This will not install any breaking changes.
            -- For major updates, this must be adjusted manually.
            -- branch = "pd-nvim",
            -- dev = true,
            -- version = "^1.0.0",
          },
          'julianolf/nvim-dap-lldb',
          'mfussenegger/nvim-dap'
        },
        config = function()
            local dap = require 'dap'
            dap.adapters.cppdbg = {
                id = 'cppdbg',
                type = 'executable',
                command = vim.fn.expand("~/.local/share/nvim/mason/bin/OpenDebugAD7"),
            }
            -- if mac, use lldb, otherwise use cppdbg
            local config_type = "cppdbg"
            if vim.fn.has("mac") == 1 then
                config_type = "lldb"
            end
            local function reload_pd_nvim()
              -- debugger config
              -- detect .pdproj file from current project
              -- detect .pdproj file from current project
              local pdproj_path = vim.fn.findfile('.pdproj', vim.fn.getcwd() .. ';')
              if pdproj_path ~= '' then
                  pdproj_path = vim.fn.fnamemodify(pdproj_path, ':p')
                  print(".pdproj file detected at: " .. pdproj_path)
              else
                  -- try to get it from env:PD_PROJ
                  pdproj_path = os.getenv("PD_PROJ") or ''
              end

              -- require pdproj_path as lua file
              --
              local pdsetup_fn = loadfile(pdproj_path)
              local pdsetup = pdsetup_fn and pdsetup_fn() or {}
              require 'pd_nvim'.setup(pdsetup)
            end
            -- add autocmd to reload pd_nvim on .pdproj save
            vim.api.nvim_create_autocmd("BufWritePost", {
                pattern = ".pdproj",
                callback = function()
                    print(".pdproj file saved, reloading pd_nvim config...")
                    reload_pd_nvim()
                end,
            })

            -- PDReload command
            --
            vim.api.nvim_create_user_command("PdReload", function()
                print("Reloading pd_nvim config...")
                reload_pd_nvim()
            end, {})
            reload_pd_nvim()
        end,
        dev = true
    },
    -- folding that actually works
    {
        'kevinhwang91/nvim-ufo',
        dependencies = { 'kevinhwang91/promise-async' },
        config = function()
            vim.o.foldcolumn = '1' -- '0' is not bad
            vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
            vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

            require('ufo').setup({
                provider_selector = function(bufnr, filetype, buftype)
                    return { 'treesitter', 'indent' }
                end
            })
        end
    },
    'paretje/nvim-man',
    -- Git related plugins
    {
        'tpope/vim-fugitive',
        config = function()
          local gitconfig = require 'config.git.fugitive'
          require 'which-key'.add(gitconfig.which_key_bindings)
        end
    },
    'tpope/vim-rhubarb',
    {
        'APZelos/blamer.nvim',
        config = function()
            vim.cmd [[
      augroup Blamer
        autocmd!
        autocmd BufEnter * BlamerShow
      augroup END
    ]]
        end
    },

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',
    -- NOTE: This is where your plugins related to LSP can be installed.
    --  The configuration is done below. Search for lspconfig to find it below.
    { 'folke/neodev.nvim',    config = true },
    {
        -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Automatically install LSPs to stdpath for neovim
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',
            { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

        },
    },

    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds LSP completion capabilities
            'hrsh7th/cmp-nvim-lsp',

            -- Adds a number of user-friendly snippets
            -- 'rafamadriz/friendly-snippets',
        },
    },

    -- Useful plugin to show you pending keybinds.
    { 'folke/which-key.nvim', opts = {},    dependencies = { 'echasnovski/mini.nvim' } },
    {
        'xiyaowong/transparent.nvim',
        config = function()
            require("transparent").setup({ -- Optional, you don't have to run setup.
                groups = {                 -- table: default groups
                    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
                    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
                    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
                    'SignColumn', 'CursorLine', 'CursorLineNr', 'StatusLine', 'StatusLineNC',
                    'EndOfBuffer',
                },
                extra_groups = {},   -- table: additional groups that should be cleared
                exclude_groups = {}, -- table: groups you don't want to clear
            })
            vim.cmd("TransparentEnable")
        end
    },
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        config = function()
          local gitconfig = require "config.git.gitsigns"
          require("gitsigns").setup(gitconfig)
        end,
    },

    {
        'akinsho/toggleterm.nvim',
        config = true
    },
    {
        'm4xshen/autoclose.nvim',
        opts = {
            keys = {
                ["("] = { escape = false, close = true, pair = "()" },
                ["["] = { escape = false, close = true, pair = "[]" },
                ["{"] = { escape = false, close = true, pair = "{}" },

                [">"] = { escape = true, close = false, pair = "<>" },
                [")"] = { escape = true, close = false, pair = "()" },
                ["]"] = { escape = true, close = false, pair = "[]" },
                ["}"] = { escape = true, close = false, pair = "{}" },

                ['"'] = { escape = true, close = true, pair = '""' },
                ["'"] = { escape = true, close = true, pair = "''" },
                ["`"] = { escape = true, close = true, pair = "``" },
            },
            options = {
                disabled_filetypes = { "text" },
                disable_when_touch = false,
                touch_regex = "[%w(%[{]",
                pair_spaces = false,
                auto_indent = true,
            },
        }
    },

    {
        'goolord/alpha-nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require 'alpha'.setup(require 'alpha.themes.startify'.config)
            vim.keymap.set("n", "<leader><BS>", "<cmd>Alpha<cr>")
        end
    },
    {
        'pwntester/octo.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            -- OR 'ibhagwan/fzf-lua',
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require "octo".setup()
        end
    },

    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                theme = 'onedark',
                component_separators = '|',
                section_separators = '',
            },
        },
    },

    {
        -- liminal 🦈 indenting
        'lukas-reineke/indent-blankline.nvim',
        config = function()
            local highlight = {
                "RainbowCyan",
                "RainbowPink",
                "RainbowWhite",
                "RainbowPink",
                "RainbowCyan",
            }

            local hooks = require "ibl.hooks"
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "RainbowPink", { fg = "#BC8F8F" })
                vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
                vim.api.nvim_set_hl(0, "RainbowWhite", { fg = "#FFFFFF" })
            end)

            require("ibl").setup {
                indent = {
                    highlight = highlight,
                },
            }
        end
    },

    -- "gc" to comment visual regions/lines
    { 'numToStr/Comment.nvim', opts = {} },

    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Fuzzy Finder Algorithm which requires local dependencies to be built.
            -- Only load if `make` is available. Make sure you have the system
            -- requirements installed.
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                -- NOTE: If you are having trouble with this installation,
                --       refer to the README for telescope-fzf-native for more instructions.
                build = 'make',
                cond = function()
                    return vim.fn.executable 'make' == 1
                end,
            },
            {
                'ahmedkhalf/project.nvim',
                keys = {
                    { "<leader>pp", "<cmd>Telescope projects<cr>", desc = "Telescope projects" },
                    { "<leader>sp", "<cmd>Telescope projects<cr>", desc = "Telescope projects" }
                },
                config = function()
                    require 'project_nvim'.setup {
                        -- Manual mode doesn't automatically change your root directory, so you have
                        -- the option to manually do so using `:ProjectRoot` command.
                        manual_mode = false,

                        -- Methods of detecting the root directory. **"lsp"** uses the native neovim
                        -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
                        -- order matters: if one is not detected, the other is used as fallback. You
                        -- can also delete or rearangne the detection methods.
                        detection_methods = { "pattern", "lsp" },

                        -- All the patterns used to detect root dir, when **"pattern"** is in
                        -- detection_methods
                        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },

                        -- Table of lsp clients to ignore by name
                        -- eg: { "efm", ... }
                        ignore_lsp = {},

                        -- Don't calculate root dir on specific directories
                        -- Ex: { "~/.cargo/*", ... }
                        exclude_dirs = {},

                        -- Show hidden files in telescope
                        show_hidden = false,

                        -- When set to false, you will get a message when project.nvim changes your
                        -- directory.
                        silent_chdir = true,

                        -- What scope to change the directory, valid options are
                        -- * global (default)
                        -- * tab
                        -- * win
                        scope_chdir = 'global',

                        -- Path where project.nvim will store the project history for use in
                        -- telescope
                        datapath = vim.fn.stdpath("data"),
                    }
                end,
            },
        },
    },

    {
  -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects'
  },
  config = function()
  require('nvim-treesitter.install').compilers = { 'clang', 'gcc' }

    local parsers = {
      'bash',
      'c',
      'cpp',
      'diff',
      'go',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'rust',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
    }

    local to_install = {}
    for _, lang in ipairs(parsers) do
      -- Native Neovim check: returns true if the .so/.dylib grammar exists
      local installed = pcall(vim.treesitter.get_string_parser, '', lang)
      if not installed then
        table.insert(to_install, lang)
      end
    end

    if #to_install > 0 then
      vim.cmd('TSInstall ' .. table.concat(to_install, ' '))
    end

    vim.api.nvim_create_autocmd({ 'FileType', 'BufReadPost' }, {
      group = vim.api.nvim_create_augroup('TreesitterAutoStart', { clear = true }),
      callback = function(ev)
      -- Skip special non-file buffers (terminals, quickfix, help windows, etc.)
      local buftype = vim.bo[ev.buf].buftype
      if buftype ~= '' then
        return
      end

      -- Attempt to start treesitter highlighting safely
      pcall(vim.treesitter.start, ev.buf)
  end,
})

  end,
},

{
  -- Show context of current function/class at the top of the buffer
  'nvim-treesitter/nvim-treesitter-context',
  event = 'BufReadPost',
  cond = function()
    return vim.g.vscode == nil
  end,
  opts = {
    enable = true,
    max_lines = 3,
  },
},


    -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
    --       These are some example plugins that I've included in the kickstart repository.
    --       Uncomment any of the lines below to enable them.
    require 'kickstart.plugins.autoformat',
    -- require 'kickstart.plugins.debug',
}

return lazySpecs
