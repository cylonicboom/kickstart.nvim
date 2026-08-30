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

vim.cmd("autocmd FileType fugitive nmap <buffer> za =")

return {
    which_key_bindings = {
		{ "<leader>g",  group = "git" },
		{ "<leader>gA", group = "Git Add" },
		{ "<leader>gD", group = "Git Diff" },
		{ "<leader>gF", group = "Git Fetch" },
		{ "<leader>gP", group = "Git Push" },
	}
}
