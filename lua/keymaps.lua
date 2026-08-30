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

vim.keymap.set("n", "<leader>fs", ":w<cr>", { desc = "[F]ile [S]ave" })
vim.keymap.set("n", "<leader>w", "<C-w>")
vim.keymap.set("i", "jk", "<esc><esc>")

vim.keymap.set("n", "<leader>oT", "<cmd>term<cr>", { desc = "Open Terminal in place" })
vim.keymap.set("n", "<leader>ot", "<cmd>term<cr>", { desc = "Open Terminal in place" })

vim.keymap.set("n", "<leader>Ss", "<cmd>mksession! ~/session.nvim<cr>", { desc = "Save Session" })
vim.keymap.set("n", "<leader>Sl", "<cmd>source ~/session.nvim<cr>", { desc = "Load Session" })

vim.keymap.set("n", "<leader>th", "gT", { desc = "previous tab" })
vim.keymap.set("n", "<leader>tl", "gt", { desc = "next tab" })
vim.keymap.set("n", "<leader>tq", "<cmd>tabclose<cr>", { desc = "close tab" })
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<cr>", { desc = "new tab" })
vim.keymap.set("t", "jk", "<C-\\><C-n>")
vim.cmd("xnoremap < <gv")
vim.cmd("xnoremap > >gv")
vim.keymap.set("n", "vse", "<cmd>vs|Explore|vertical resize 60<cr>", { desc = "Explore vertically" })
vim.keymap.set("n", "se", "<cmd>sp|Explore|resize 20<cr>", { desc = "Explore horizontally" })
vim.keymap.set('n', "qq", "<cmd>q<cr>")
vim.keymap.set("n", "<leader>E", "<cmd>Explore<cr>", { desc = "Explore" })
vim.keymap.set("n", "<leader>QQQ", "<cmd>qa!<cr>", { desc = "Quit immediately" })
vim.keymap.set("n", "<leader><C-a>", "<cmd>Alpha<cr>", { desc = "Alpha" })
