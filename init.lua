--[[
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
local vim = _G['vim']
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }
end

vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup calm
--    as they will be available in your neovim runtime.
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
            require 'which-key'.add
            {
                { "<leader>g",  group = "git" },
                { "<leader>gA", group = "Git Add" },
                { "<leader>gD", group = "Git Diff" },
                { "<leader>gF", group = "Git Fetch" },
                { "<leader>gP", group = "Git Push" },
            }
            vim.keymap.set('n', '<leader>gg', '<cmd>G<cr>', { desc = "fuGitive status" })
            vim.keymap.set('n', '<leader>G', ':G ', { desc = "run git command" })
            vim.keymap.set('n', '<leader>gF', ':G fetch <cr>', { desc = '[G]it [F]etch' })
            vim.keymap.set('n', '<leader>gm', ':G merge ', { desc = "[G]it [M]erge" })
            vim.keymap.set('n', '<leader>gp', ':G push ', { desc = "[G]it [P]ush" })
            vim.keymap.set('n', '<leader>gP', ':G push<cr>', { desc = "[G]it [P]ush" })
            vim.keymap.set('n', '<leader>gA', ':G add %<cr>', { desc = "[G]it [A]dd" })
            vim.keymap.set('n', '<leader>gC', ':G commit<cr>', { desc = "[G]it [C]ommit" })
            vim.keymap.set('n', '<leader>gDD', '<cmd>G diff<cr>', { desc = "[G]it [D]iff" })
            vim.keymap.set('n', '<leader>gDC', '<cmd>G diff --cached<cr>', { desc = "[G]it [D]iff --[c]ached" })
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
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
            on_attach = function(bufnr)
                vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
                    { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
                vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk,
                    { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
                vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk,
                    { buffer = bufnr, desc = '[P]review [H]unk' })
            end,
        },
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

require 'lazy'.setup(lazySpecs, {
    dev = {
        path = "~/src",
        package = { "pd-nvim" }
    }
})

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})






-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
    -- clangd = {},
    -- gopls = {},
    -- pyright = {},
    -- rust_analyzer = {},
    -- tsserver = {},
    -- html = { filetypes = { 'html', 'twig', 'hbs'} },

    emmylua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

for server_name, _ in pairs(servers) do
    vim.lsp.enable(server_name)
end

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert {
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete {},
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    },
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = "dap" }
    },
}




vim.cmd("autocmd FileType fugitive nmap <buffer> za =")

local termreg = require("termreg")
require("keymaps")
require("opts")
require("config.telescope")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
