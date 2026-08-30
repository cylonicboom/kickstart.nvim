--- The purpose of this module
--- is to tag terminals with a friendly name so I can
--- work with them more easilly
local M = {}

--- Retrieve or create a terminal buffer associated with a persistent tag
---@param tag string The register tag (e.g., "projects", "build", "server")
---@return integer bufnr, integer channel
function M.get_or_create(tag)
  -- 1. Search existing buffers for the persisted 'TermTag' variable
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
      local ok, value = pcall(vim.api.nvim_buf_get_var, buf, 'TermTag')
      if ok and value == tag then
        return buf, vim.bo[buf].channel
      end
    end
  end

  -- 2. Create a new buffer if no matching tagged terminal exists
  local buf = vim.api.nvim_create_buf(false, false)
  vim.bo[buf].buftype = 'terminal'

  -- Attach the capitalized Vimscript variable for session restoration
  vim.api.nvim_buf_set_var(buf, 'TermTag', tag)

  -- Open terminal process in buffer
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.fn.termopen(vim.o.shell)

  return buf, vim.bo[buf].channel
end

--- Send a shell command to a tagged terminal register without switching focus
---@param tag string Register name
---@param cmd string Shell command to run
function M.send(tag, cmd)
  local _, chan = M.get_or_create(tag)
  if chan and chan > 0 then
    vim.api.nvim_chan_send(chan, cmd .. '\n')
  else
    vim.notify('Failed to send command to terminal [' .. tag .. ']', vim.log.levels.ERROR)
  end
end

--- Jump directly to the tagged terminal buffer
---@param tag string Register name
function M.focus(tag)
  local buf, _ = M.get_or_create(tag)
  vim.api.nvim_set_current_buf(buf)
end

return M
