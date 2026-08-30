-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

-- 1. Create the capabilities table
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- 2. Apply it globally to all LSP servers
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- 3. Enable your servers (e.g., clangd for C/C++, lua_ls for Lua)
vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')

local builtin = require('telescope.builtin')


vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    -- Helper function to set keymaps with clean desc options
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end

    -- Code Navigation (Standard gd, gD, gi, gt)
    map('n', '<leader>lgd', vim.lsp.buf.definition, 'Go to Definition')
    map('n', '<leader>lgD', vim.lsp.buf.declaration, 'Go to Declaration')
    map('n', '<leader>lgi', vim.lsp.buf.implementation, 'Go to Implementation')
    map('n', '<leader>lgt', vim.lsp.buf.type_definition, 'Go to Type Definition')
    --
    -- Jump to references across the whole codebase
    vim.keymap.set('n', '<leader>lsr', builtin.lsp_references, { desc = 'Find References' })

    -- Fuzzy search symbols (functions, structs, globals) in current file
    vim.keymap.set('n', '<leader>lsd', builtin.lsp_document_symbols, { desc = 'Document Symbols' })

    -- Fuzzy search symbols across the ENTIRE C project
    vim.keymap.set('n', '<leader>lsw', builtin.lsp_workspace_symbols, { desc = 'Workspace Symbols' })

    -- Hover & Documentation
    map('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
    map({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, 'Signature Help')

    -- Code Actions & Refactoring
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename Symbol')
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  end,
})

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
