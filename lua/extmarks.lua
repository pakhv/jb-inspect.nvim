local utils = require 'utils'

local M = {}

local JB_ISSUES_NAMESPACE = 'JbIssuesNamespace'
local function get_highlight_group(hg)
  local hg_code = utils.INSPECTION_LEVEL[hg]

  if hg_code == nil or hg_code == 2 then
    return 'Character'
  elseif hg_code == 0 then
    return 'ErrorMsg'
  elseif hg_code == 1 then
    return 'WarningMsg'
  end
end

function M.create(text, l_num, c_num, hg)
  local ns_id = vim.api.nvim_get_namespaces()[JB_ISSUES_NAMESPACE]

  if (ns_id == nil) then
    ns_id = vim.api.nvim_create_namespace(JB_ISSUES_NAMESPACE)
  end

  vim.api.nvim_buf_set_extmark(vim.fn.bufnr(), ns_id, l_num, c_num,
    { virt_text = { { ' ' .. text, get_highlight_group(hg) } }, virt_text_pos = 'eol' })
end

function M.clear()
  local ns_id = vim.api.nvim_get_namespaces()[JB_ISSUES_NAMESPACE]

  if (ns_id == nil) then
    return
  end

  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

return M
