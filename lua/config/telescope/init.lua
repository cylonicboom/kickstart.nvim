-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ['<C-u>'] = false,
                ['<C-d>'] = false,
            },
        },
        preview = {
          treesitter = false
        }
    },
}


-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

local refresh_projects = function()
  local script_path = vim.fn.expand('~/.config/nvim/sh/mk-vimprojects.sh')
  
  -- Use vim.uv (Neovim 0.10+) or fallback to vim.loop
  local uv = vim.uv or vim.loop

  uv.spawn(script_path, {
    detach = true,
  }, function(code, signal)
    if code == 0 then
      vim.schedule(function()
        vim.notify('Projects refreshed successfully', vim.log.levels.INFO)
      end)
    else
      vim.schedule(function()
        vim.notify('Project refresh failed with code ' .. code, vim.log.levels.ERROR)
      end)
    end
  end)
end

vim.keymap.set('n', '<leader>pr', refresh_projects, { desc = '[p]roject [r]efresh' })
refresh_projects()
require('telescope').load_extension('projects')
--
-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set("n", "<leader>sj", "<cmd>Telescope jumplist<cr>", { desc = "Telescope jumplist" })

vim.keymap.set('n', '<leader>\'', require('telescope.builtin').resume, { desc = 'Resume last telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>gd', require('telescope.builtin').git_status, { desc = 'Search [G]it [S]tatus' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sb', require('telescope.builtin').buffers, { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>bb', require('telescope.builtin').buffers, { desc = '[B]eautiful [B]uffers' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').pickers, { desc = '[S]earch by [S]earches' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.api.nvim_set_keymap('n', '<leader>s*',
    '<cmd>lua require(\'telescope.builtin\').grep_string({search = vim.fn.expand("<cword>")})<cr>', {})
